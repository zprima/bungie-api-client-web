class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :access_token, type: String
  field :token_type, type: String
  field :expires_at, type: Integer
  field :refresh_token, type: String
  field :refresh_expires_at, type: Integer
  field :membership_id, type: String


  def self.find_or_create_from_auth(auth_info)
    user = self.find_or_initialize_by(membership_id: auth_info['membership_id'])
    user.access_token = auth_info['access_token']
    user.token_type = auth_info['token_type']
    user.expires_at = auth_info['expires_at']
    user.refresh_token = auth_info['refresh_token']
    user.refresh_expires_at = auth_info['refresh_expires_at']
    user.save

    user
  end

  def refresh_access_token
    token_info = BungieAuthService.get_valid_token(
      access_token: self.access_token, 
      expires_at: self.expires_at,
      refresh_token: self.refresh_token,
      refresh_expires_at: self.refresh_expires_at
    )

    if token_info['access_token'] != self.access_token
      self.access_token = token_info['access_token']
      self.expires_at = token_info['expires_at']
      self.save
    end

    self.access_token
  end
end