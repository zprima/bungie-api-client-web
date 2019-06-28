class DestinyProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :bungie_membership_id, type: String
  field :components, type: Hash

  def self.refresh_for(user:, membership_id:, membership_type:)
    response = BungieApiService.new(user).get_profile(membership_type, membership_id)
    profile = self.find_or_initialize_by(bungie_membership_id: user.membership_id)
    profile.components = response["Response"]
    profile.save
  end

  def self.for(user)
    DestinyProfile.find_by(bungie_membership_id: user.membership_id)
  end

  def profile_inventory
    components['profileInventory']['data']
  end

  def profile_currency
    components['profileCurrency']
  end

  def profile_collectibles
    components['profileCollectibles']
  end

  def characters
    components['characters']['data']
  end

  def character_inventories
    components['characterInventories']['data']
  end

  def character_progressions
    components['characterProgressions']['data']
  end

  def character_equipment
    components['characterEquipment']['data']
  end

  def character_plug_sets
    components['characterPlugSets']
  end

  def character_uninstanced_item_components
    components['characterUninstancedItemComponents']
  end

  def character_collectibles
    components['characterCollectibles']
  end

  def item_components
    components['itemComponents']
  end
end