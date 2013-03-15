require 'json'
require 'net/http'
require 'pry'
require 'parallel'

class Har

  def initialize(file)
    @request_archive = JSON.parse(File.read(file))['request']
    @request_url = URI(@request_archive['url'])
  end

  def replay!
    http = Net::HTTP.new(@request_url.host, @request_url.port)
    request = request_method.new(@request_url.request_uri)
    @request_archive['headers'].each do |header|
      request[header['name']] = header['value']
    end
    query = Hash[@request_archive['queryString'].map(&:values)]
    request.set_form_data(query)
    response = http.request(request)
    binding.pry
    puts response
  end

  def request_method
    Net::HTTP.const_get(@request_archive['method'].capitalize)
  end
end

har = Har.new('/Users/Gray/Desktop/vote-js.php.har')

har.replay!