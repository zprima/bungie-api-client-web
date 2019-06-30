class InventoriesController < ApplicationController
  def index
    @local_item_def = {}
    @local_dmg_def = {}
    @local_stat_group_def = {}
    @local_stat_def = {}

    build_character_equipment
    build_character_inventory
    build_vault
  end

  def get_item_def(item_hash)
    x = @local_item_def[item_hash]
    return x if x
    
    x = item_definitions.find_by(definition_hash: item_hash).definition
    @local_item_def[item_hash] = x
    x
  end

  def get_dmg_def(damage_type_hash)
    x = @local_dmg_def[damage_type_hash]
    return x if x

    x = dmg_type_definitions.find_by(definition_hash: damage_type_hash).definition
    @local_dmg_def[damage_type_hash] = x
    x
  end

  def get_stat_group_def(stat_group_hash)
    x = @local_stat_group_def[stat_group_hash]
    return x if x

    x = stat_group_definitions.find_by(definition_hash: stat_group_hash).definition
    @local_stat_group_def[stat_group_hash] = x
    x
  end

  def get_stat_def(stat_hash)
    x = @local_stat_def[stat_hash]
    return x if x
    
    x = stat_definitions.find_by(definition_hash: stat_hash).definition
    @local_stat_def[stat_hash] = x
    x
  end

  def build_vault
    @profile_inventory = profile
      .profile_inventory['items']
      .select{|x| x['bucketHash'] == DestinyInventoryBucket.general }

      @profile_inventory = @profile_inventory.map do |pi|
        item_def = get_item_def(pi['itemHash'])
        instance_def = if pi['itemInstanceId']
          instance_definitions[pi['itemInstanceId']]
        else 
          {}
        end
  
        {
          'pi' => pi,
          'item_def' => item_def,
          'instance_def' => instance_def,
          'bucket_type_hash' => item_def['inventory']['bucketTypeHash'],
        }
      end.sort_by do |x| 
        [
          x['item_def']['inventory']['bucketTypeHash'],
          x['item_def']['displayProperties']['name'],
          x['item_def']['inventory']['tierTypeName'],
          (x['instance_def']['primaryStat'] ? x['instance_def']['primaryStat']['value'] : 0)
        ]
      end.group_by{|x| x['bucket_type_hash']}
  end

  def build_character_inventory
    @character_inventory = profile
      .character_inventories[current_character_id]['items']
      .select{|x| buckets.include?(x['bucketHash'])}

      @character_inventory = @character_inventory.map do |char|
        item_def = get_item_def(char['itemHash'])
        instance_def = if char['itemInstanceId']
          instance_definitions[char['itemInstanceId']]
        else 
          {}
        end
  
        {
          'ci' => char,
          'item_def' => item_def,
          'instance_def' => instance_def
        }
      end
  end

  def build_character_equipment
    _character_equipment = profile
      .character_equipment[current_character_id]['items']
      .select{|x| buckets.include?(x['bucketHash'])}

    @character_equipment = _character_equipment.map do |char|
      item_def = get_item_def(char['itemHash'])
      dmg_def = get_dmg_def(item_def['defaultDamageTypeHash'])

      instance_def = if char['itemInstanceId']
        instance_definitions[char['itemInstanceId']]
      else 
        {}
      end

      stat_group = get_stat_group_def(item_def['stats']['statGroupHash'])

      stats = item_def['stats']['stats'].map do |key, value|
        stat_def = get_stat_def(key)

        calculated_value = value['value']
        scaling = stat_group['scaledStats'].find{|x| x['statHash'] == value['statHash'].to_s}
        if scaling
          result = scaling['displayInterpolation'].find{|x| x['value'] == value['value'].to_s}
          calculated_value = result['weight'] if result
        end

        {
          'stat_def' => stat_def,
          'stat' => value,
          'value' => calculated_value
        }
      end.sort_by{|x| x['stat_def']['displayProperties']['name'] }

      {
        'char_equip' => char,
        'item_def' => item_def,
        'dmg_def' => dmg_def,
        'instance_def' => instance_def,
        'stats' => stats,
        'stat_group' => stat_group
      }
    end
  end

  private

  def buckets
    @buckets ||= [
      DestinyInventoryBucket.kineticWeapons,
      DestinyInventoryBucket.energyWeapons,
      DestinyInventoryBucket.powerWeapons
    ]
  end

  def item_definitions
    @item_definitions ||= DestinyManifest.for(DestinyDefinition.inventoryItem)
  end

  def dmg_type_definitions 
    @dmg_type_definitions ||= DestinyManifest.for(DestinyDefinition.damageType)
  end

  def stat_definitions 
    @stat_definitions ||= DestinyManifest.for(DestinyDefinition.stat)
  end

  def stat_group_definitions 
    @stat_group_definitions ||= DestinyManifest.for(DestinyDefinition.statGroup)
  end

  def profile
    @profile ||= DestinyProfile.for(current_user)
  end

  def instance_definitions
    @instance_definitions ||= profile.item_components['instances']['data']
  end
end
