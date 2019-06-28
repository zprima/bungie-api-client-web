class BungieAuthService

  def self.get_login_link
    state = SecureRandom.hex()

    url_string = 
      "#{ENV['BUNGIE_AUTH_URL']}" +
      "?client_id=#{ENV['BUNGIE_CLIENT_ID']}" +
      "&response_type=code" +
      "&state=#{state}"

    URI(url_string).to_s
  end

  def self.get_token(data)
    client = ApiClientService.new(with_basic_auth: true)
    response = client.post(path: ENV['BUNGIE_AUTH_TOKEN_PATH'], body: data)
  
    return response if response.key?(:error)

    time_now = Time.now.to_i

    auth_info = response

    auth_info['expires_at'] =
      time_now + auth_info['expires_in']
    
    if auth_info['refresh_expires_in']
      auth_info['refresh_expires_at'] =
        time_now + auth_info['refresh_expires_in']
    end

    auth_info
  end

  def self.get_access_token(code)
    data = {
      grant_type: "authorization_code",
      code: code,
      client_id: ENV['BUNGIE_CLIENT_ID']
    }
    get_token(data)
  end

  def self.get_refresh_token(refresh_token)
    data = {
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      client_id: ENV['BUNGIE_CLIENT_ID']
    }
    get_token(data)
  end

  def self.get_valid_token(access_token:, expires_at:, refresh_token: nil, refresh_expires_at: nil)
    time_now = Time.now.to_i
    return { 'access_token' => access_token } if expires_at > time_now

    if refresh_token.nil?
      raise Errors::BungieApiError, 'Token expired, need to re-auth'
    end

    if refresh_expires_at < time_now
      raise Errors::BungieApiError, 'Refresh token expired, need to re-auth'
    end

    get_refresh_token(refresh_token)
  end
end