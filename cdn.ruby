require 'rest-client'
require 'json'
require 'time'
require 'base64'

#IDCクラウド コンテンツキャッシュ削除API

api_key = ""
secret_key = ""

cdn_url = "https://cdn.idcfcloud.com/api/v0/caches"
method = "DELETE"
uri = "/api/v0/caches" #固定

expired = Time.now.to_i + 1200 #20分加算
delete_path = ""
delete_expired = Time.now.to_i + 3*60*60 #max_age分加算 現在3時間

#request bosy
params = {api_key: api_key, delete_path: delete_path, expired: delete_expired}.to_json

#create sginature
str = method + "\n" + api_key + "\n" + secret_key + "\n" + expired.to_s + "\n" + uri + "\n" + params
signature = Base64.strict_encode64(OpenSSL::HMAC.hexdigest('sha256', secret_key, str)) 

#add request headers
headers = {expired: expired, signature: signature}

begin
  RestClient.log = 'stdout'
  RestClient::Request.execute(
    :method => :delete,
    :url => cdn_url,
    :payload => params,
    :headers => headers
  )
rescue => e
  puts e.response
end

