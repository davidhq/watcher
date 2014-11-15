set :output, "/var/www/watcher/log/cron_log.log"

every 1.minute do
  command "ruby /var/www/watcher/watch.rb server"
end
