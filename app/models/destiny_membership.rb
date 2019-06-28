class DestinyMembership
  include Mongoid::Document
  include Mongoid::Timestamps

  field :bungie_membership_id, type: String
  field :membership_type, type: Integer
  field :membership_id, type: String
  field :icon_path, type: String
  field :display_name, type: String
  
  def self.prepare_for(membership_id:, data:)
    data.each do |membership_data|
      membership = self.find_or_initialize_by(
        bungie_membership_id: membership_id, 
        membership_id: membership_data['membershipId'],
        membership_type: membership_data['membershipType']
      )
      membership.icon_path = membership_data["iconPath"]
      membership.display_name = membership_data["displayName"]
      membership.save
    end
  end
end