#!/usr/bin/env ruby
require 'json'
require 'colorize'
require "benchmark"
require_relative 'sms'
require_relative 'email'
require_relative 'checker'
require_relative 'status'
require_relative 'config'

def growl(msg)
  `growlnotify -n "Watcher" -m "#{msg}"`
end

checker = Checker.new
sites = Config.load['sites']
statuses = Status.read(sites)

down = false
local = ARGV[0] == 'local' # local cron
server = ARGV[0] == 'server' # server cron

# - if the same error 2 times in a row
# - if this report is different than last
screen, msg = checker.report(sites, statuses, local: local, server: server)
print screen

#puts "\nEverything up and running".yellow unless msg || local || server

if msg
  subject = "Server Problems"

  if local
    growl_msg = "#{subject}:\n\n#{msg.gsub(' | ', "\n")}"
    growl(growl_msg)
  end

  if phone = Config.load['user']['phone'] and server
    #puts "SMS: #{msg}"
    Sms.new.send(phone, "#{subject}: #{msg}")
  end
end

Status.write(statuses)


