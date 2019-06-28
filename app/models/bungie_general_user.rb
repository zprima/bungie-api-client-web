class BungieGeneralUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :membership_id, type: String
  field :unique_name, type: String
  field :display_name, type: String
  field :psn_display_name, type: String
  field :xbox_display_name, type: String
  field :fb_display_name, type: String
  field :blizzard_display_name, type: String
  field :profile_picture_path, type: String
  
  def self.prepare_for(membership_id:, data:)
    general_user = self.find_by(membership_id: membership_id)
    general_user = self.new if general_user.nil?

    general_user.membership_id = data['membershipId']
    general_user.unique_name = data['uniqueName']
    general_user.display_name = data['displayName']
    general_user.psn_display_name = data['psnDisplayName']
    general_user.xbox_display_name = data['xboxDisplayName']
    general_user.fb_display_name = data['fbDisplayName']
    general_user.blizzard_display_name = data['blizzardDisplayName']
    general_user.profile_picture_path = data['profilePicturePath']
    general_user.save
  end
end


