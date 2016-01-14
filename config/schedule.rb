set :output, "/var/www/watcher/log/cron_log.log"

every 2.minutes do
  command "ruby /var/www/watcher/watch.rb server"
end
