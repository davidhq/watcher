require 'pony'
require_relative 'config'

class Email

  def send(email, subject, message)
    Pony.mail({
      to: email,
      subject: subject,
      body: message,
      from: Config.load['user']['email'],
      via: :smtp,
      via_options: smtp_options
    })
  end

private

  def smtp_options
    {
      address:        'smtp.mandrillapp.com',
      port:           587,
      user_name:      Config.load['mandrill']['user'],
      password:       Config.load['mandrill']['password'],
      authentication: :plain,
      domain:         "watcher.dev"
    }
  end

end
