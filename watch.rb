require 'json'
require 'colorize'
require "benchmark"
require_relative 'sms'
require_relative 'email'
require_relative 'checker'
require_relative 'config'

checker = Checker.new

def bad_status(status)
  ![200, 302].include?(status)
end

sites = Config.load['sites']

status = {}

status_file = File.join(File.dirname(__FILE__), 'status.json')
if File.exists?(status_file)
  status = JSON.parse(File.read(status_file))
  for site in status.keys
    if sites.find { |s| s['name'] == site }
      status[site]['prev_status'] = status[site]['status']
    else
      status.delete site
    end
  end
end

for site in sites
  status[site['name']] = {} unless status[site['name']]
end

msg = ''
down = false
local = ARGV[0] == 'local'
server = ARGV[0] == 'server'

for site in status.keys
  print "#{site}: " unless server || local
  time = Benchmark.realtime do
    result = checker.status(sites.find { |s| s['name'] == site }['url'])
    unless result == 'ssl_error'
      status[site]['status'] = result
      status[site]['count'] = status[site]['status'] == status[site]['prev_status'] ? status[site]['count'].to_i + 1 : 1
    end
  end
  stat = status[site]['status']
  if bad_status(stat) && stat != 'timeout' && (bad_status(status[site]['prev_status']) || local) && !status[site]['reported']
    msg += "#{site} (#{stat}) | "
    status[site]['reported'] = true
  end
  if bad_status(stat)
    if stat == 'timeout'
      #down ||= status[site]['count'] >= 5 # 5th consecutive timeout is an alarm since these timeouts happen because of random network issues
    else
      down = true
    end
    if !local || (local && !['noconn', 'sslerror'].include?(stat))
      puts (server ? "#{site} down (#{stat})" : "DOWN (#{stat})".red)
    end
  elsif !(server || local)
    puts "OK".green + " (#{time.round(2)}s)"
  end
  status[site]['reported'] = false unless bad_status(stat)
end

puts 'Everything up and running' unless down || local || server

unless msg == ''
  msg = msg.strip.chomp('|')
  subject = 'Server Problems'
  if email = Config.load['user']['email'] and server || local
    begin
      Email.new.send(email, subject, msg)
    rescue # sending from local machine without connection
    end
  end
  if phone = Config.load['user']['phone'] and server
    Sms.new.send(phone, "#{subject}: #{msg}")
  end
end

File.open(status_file, 'w') { |file| file.puts status.to_json }


