class BungieApiService

  def initialize(user)
    @user = user
    @token = @user.refresh_access_token
  end

  def self.get_destiny_manifest
    path = 'Destiny2/Manifest/'
    client = ApiClientService.new()
    client.get(path: path)
  end

  def get_memberships_for_current_user
    path = 'User/GetMembershipsForCurrentUser/'
    client = ApiClientService.new(access_token: @token)
    client.get(path: path)
  end

  def get_profile(membership_type, membership_id)
    path = "Destiny2/#{membership_type}/Profile/#{membership_id}"

    data = {
      components: '102,103,200,201,202,205,300,301,304,305,306,307,308,800'
    }

    client = ApiClientService.new(access_token: @token)
    client.get(path: path, qs_params: data)
  end
end