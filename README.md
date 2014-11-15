# Watcher

Watch sites and send email and sms when they are down or broken (status ≠ 200 || 302).

Sites are checked every minute and if status code is not ok twice in a row, notification is sent. Notification is not sent again until status is ok at least once in an intermediate check.

## Setup and test

* `bundle install`

* `cp config.yml.sample config.yml`

* edit `config.yml`

* run `ruby watch.rb`

## Installation on server

* `bundle install`

* edit `config/schedule.rb` and update path if needed

* install cron task with `whenever -i`

## Checks from local machine

It's advisable to also run checks from local machine esp. if you have only one server and you are running `watcher` on the same instance as your websites.

You can use something like `Keyboard Maestro` like this: http://cl.ly/image/303v0A3G361Q

`local` argument makes it so that there is no output unless there are problems, also sms is not sent, only email.
