require 'xmlrpc/client'

API_KEY = ''
class ApiError < StandardError; end
def api_call(api_method, params)
  server = XMLRPC::Client.new( "soshified.com", "/forums/interface/board/index.php")
  default_params = {:api_key => API_KEY, :api_module => 'ipb'}
  merged_params = default_params.merge(params)
  begin
    server.call(api_method, merged_params)
  rescue XMLRPC::FaultException => error
    raise ApiError, error.message
  end
end

api_call('fetchForumsOptionList', {})
