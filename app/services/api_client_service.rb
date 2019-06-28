class ApiClientService
  def initialize(with_basic_auth: false, access_token: nil)
    @with_basic_auth = with_basic_auth
    @access_token = access_token

    @options = {}

    @headers = {}
    @headers['Content-Type'] = 'application/x-www-form-urlencoded'
    @headers['X-API-Key'] = ENV['BUNGIE_API_KEY']
    @headers['Authorization'] = "Bearer #{access_token}" if access_token
    
    @options[:headers] = @headers

    @url = ENV['BUNGIE_APP_URL']
  end

  def post(path:, body: {})
    handle_response(HTTParty.post(@url + path, @options.merge({body: body})))
  end

  def get(path:, qs_params: {})
    full_path = 
      unless qs_params.blank?
        query_string = URI.encode_www_form(qs_params)
        path + "?" + query_string
      else
        path
      end
    
      
    handle_response(HTTParty.get(@url + full_path, @options))
  end

  def handle_response(response)
    if response.code == 200
      return JSON.parse(response.body)
    end
    
    { error: 'Failed response', code: response.code, body: response.body }
  end

  # def post(path:, body: {})
  #   handle_response(@conn.post(path, body))
  # end

  # def get(path:, qs_params: {})
  

  #   handle_response(@conn.get(full_path))
  # end

  # def handle_response(response)
  #   if response.status == 200
  #     data = JSON.parse(response.body)
  #     return data
  #   end

  #   puts "------------"
  #   puts response.status
  #   puts response.body
  #   puts "------------"
  #   { error: 'Something failed on request', code: response.status, body: response.body }
  # end
end