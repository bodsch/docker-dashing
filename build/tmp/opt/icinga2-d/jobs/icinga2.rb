
require 'icinga2'

icingaHost         = ENV.fetch( 'ICINGA_HOST'             , 'icinga2' )
icingaApiPort      = ENV.fetch( 'ICINGA_API_PORT'         , 5665 )
icingaApiUser      = ENV.fetch( 'ICINGA_API_USER'         , 'admin' )
icingaApiPass      = ENV.fetch( 'ICINGA_API_PASSWORD'     , nil )
icingaCluster      = ENV.fetch( 'ICINGA_CLUSTER'          , false )
icingaSatellite    = ENV.fetch( 'ICINGA_CLUSTER_SATELLITE', nil )


# convert string to bool
icingaCluster   = icingaCluster.to_s.eql?('true') ? true : false

config = {
  :icinga => {
    :host      => icingaHost,
    :api       => {
      :port => icingaApiPort,
      :user => icingaApiUser,
      :password => icingaApiPass
    },
    :cluster   => icingaCluster,
    :satellite => icingaSatellite,
  }
}

icinga = Icinga2::Client.new( config )

  cib = icinga.CIBData()
  app = icinga.applicationData()

#   puts "App Info: " + app
#   puts "CIB Info: " + cib

if( cib.is_a?(String) )
  cib = JSON.parse(cib)
end

puts icinga.hostObjects()

SCHEDULER.every '5s', :first_in => 0 do |job|

  # meter widget
  # we'll update the patched meter widget with absolute values (set max dynamically)
#   host_meter        = icinga.hostObjects().count
#   host_meter_max    = icinga.hostObjects().size
#   service_meter     = icinga.service_count_problems.to_f
#   service_meter_max = icinga.service_count_all

#   puts "Meter widget: Hosts " + host_meter.to_s + "/" + host_meter_max.to_s
  #+ " Services " + service_meter.to_s + "/" + service_meter_max.to_s

  # check stats
  check_stats = [
    {"label" => "Host (active)", "value" => cib.dig('status','active_host_checks_1min')},
    #{"label" => "Host (passive)", "value" => icinga.host_passive_checks_1min},
    {"label" => "Service (active)", "value" => cib.dig('status','active_service_checks_1min')},
    #{"label" => "Service (passive)", "value" => icinga.service_passive_checks_1min},
  ]
  puts "Checks: " + check_stats.to_s


  send_event('icinga-checks', {
   items: check_stats,
   moreinfo: "Avg latency: #{cib.dig('status','avg_latency').round(2)}s",
   color: 'blue' })

end
