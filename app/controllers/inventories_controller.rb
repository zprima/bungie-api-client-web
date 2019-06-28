class InventoriesController < ApplicationController
  def index
    buckets = [
      DestinyInventoryBucket.kineticWeapons,
      DestinyInventoryBucket.energyWeapons,
      DestinyInventoryBucket.powerWeapons
    ]

    @item_definitions = DestinyManifest.for(DestinyDefinition.inventoryItem)
    @dmg_type_definitions = DestinyManifest.for(DestinyDefinition.damageType)
    @stat_definitions = DestinyManifest.for(DestinyDefinition.stat)
    @stat_group_definitions = DestinyManifest.for(DestinyDefinition.statGroup)

    profile = DestinyProfile.for(current_user)

    @character_equipment = profile
      .character_equipment[current_character_id]['items']
      .select{|x| buckets.include?(x['bucketHash'])}

    @character_inventory = profile
    .character_inventories[current_character_id]['items']
    .select{|x| buckets.include?(x['bucketHash'])}

    @profile_inventory = profile
    .profile_inventory['items']
    .select{|x| x['bucketHash'] == DestinyInventoryBucket.general }

    @instance_def = profile.item_components['instances']['data']

    @character_equipment = @character_equipment.map do |char|
      item_def = @item_definitions.find{|x| x.definition_hash == char['itemHash'].to_s}.definition
      dmg_def = @dmg_type_definitions.find{|x| x.definition_hash == item_def['defaultDamageTypeHash'].to_s}.definition
      instance_def = if char['itemInstanceId']
        @instance_def[char['itemInstanceId']]
      else 
        {}
      end

      stat_group = @stat_group_definitions.find{|x| x['definition_hash'] == item_def['stats']['statGroupHash'].to_s}.definition

      stats = item_def['stats']['stats'].map do |key, value|
        stat_def = @stat_definitions.find{|x| x['definition_hash'] == key.to_s}.definition

        calculated_value = value['value']
        if stat_group['scaledStats'].find{|x| x['statHash'] == value['statHash']}
          scaling = stat_group['scaledStats'].find{|x| x['statHash'] == value['statHash']}['displayInterpolation']
          result = scaling.find{|x| x['value'] == value['value']}
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

    @character_inventory = @character_inventory.map do |char|
      item_def = @item_definitions.find{|x| x.definition_hash == char['itemHash'].to_s}.definition
      instance_def = if char['itemInstanceId']
        @instance_def[char['itemInstanceId']]
      else 
        {}
      end

      {
        'ci' => char,
        'item_def' => item_def,
        'instance_def' => instance_def
      }
    end

    @profile_inventory = @profile_inventory.map do |pi|
      item_def = @item_definitions.find{|x| x.definition_hash == pi['itemHash'].to_s}.definition
      instance_def = if pi['itemInstanceId']
        @instance_def[pi['itemInstanceId']]
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
end
