# original from: https://gist.github.com/jewzaam/efffa657c31e244131e3

require 'open-uri'
require 'json'
require 'date'
require 'yaml'

config_file = File.dirname(File.expand_path(__FILE__)) + '/../config/graphite.yml'

config = YAML::load(File.open(config_file))

config.inspect

unless config["graphite"].nil?

  server_name = config["graphite"]["server"]["name"]
  server_port = config["graphite"]["server"]["port"]

  puts "server: " + server_name.to_s
  puts "port  : " + server_port.to_s
else
  puts "no valid configuration found"
  exit
end

GRAPHITE_URL = "http://" + server_name.to_s + ":" + server_port.to_s

# Pull data from Graphite and make available to Dashing Widgets
# Heavily inspired from Thomas Van Machelen's "Bling dashboard article"

# Set the graphite host and port (ip or hostname)
# GRAPHITE_URL = 'http://172.17.0.3:8080'
INTERVAL = '1m'

# Job mappings. Define a name and set the metrics name from graphite

job_mapping = {
    'host1-load-1min' => '*.*.services.ping4.ping4.perfdata.rta.value',
    'host2-load-1min' => '*.*.services.ping4.ping4.perfdata.pl.value'
}

# Extend the float to allow better rounding. Too many digits makes a messy dashboard
class Float
    def sigfig_to_s(digits)
        f = sprintf("%.#{digits - 1}e", self).to_f
        i = f.to_i
        (i == f ? i : f)
    end
end

class Graphite
    # Initialize the class
    def initialize(url)
        @url = url
    end

    # Use Graphite api to query for the stats, parse the returned JSON and return the result
    def query(statname, since=nil)
        since ||= '1h-ago'
        print "SOURCE: #{@url}/render?format=json&target=#{statname}&from=#{since}\n"
        response = URI.parse("#{@url}/render?format=json&target=#{statname}&from=#{since}").read
        result = JSON.parse(response, :symbolize_names => true)
        return result.first
    end

    # Gather the datapoints and turn into Dashing graph widget format
    def points(name, since=nil)
        since ||= '-1min'
        stats = query name, since
        datapoints = stats[:datapoints]

        points = []
        count = 1

        (datapoints.select { |el| not el[0].nil? }).each do|item|
            points << { x: count, y: get_value(item)}
            count += 1
        end

        value = (datapoints.select { |el| not el[0].nil? }).last[0].sigfig_to_s(2)

        return points, value
    end

    def get_value(datapoint)
        value = datapoint[0] || 0
        return value.round(2)
    end

    def value(name, since=nil)
        since ||= '-10min'
        stats = query name, since
        last = (stats[:datapoints].select { |el| not el[0].nil? }).last[0].sigfig_to_s(2)

        return last
    end
end

job_mapping.each do |title, statname|
   SCHEDULER.every INTERVAL, :first_in => 0 do
        # Create an instance of our Graphite class
        q = Graphite.new GRAPHITE_URL

        # Get the current points and value. Timespan is static atm
        points, current = q.points "#{statname}", "-1hour"

        # Send to dashboard, tested supports for number, meter and graph widgets
        send_event "#{title}", { current: current, value: current, points: points }
   end
end

