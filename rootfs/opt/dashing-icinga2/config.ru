
require 'dashing'

configure do
  set :auth_token, '%AUTH_TOKEN%'
  set :default_dashboard, 'icinga2'

#  # icinga2 api config
#  set :icinga2_api_url, 'https://%ICINGA2_HOST%:%ICINGA2_PORT%'
#  #set :icinga2_api_nodename, 'clientcertificatecommonname'
#  set :icinga2_api_username, '%ICINGA2_DASHING_APIUSER%'
#  set :icinga2_api_password, '%ICINGA2_DASHING_APIPASS%'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
