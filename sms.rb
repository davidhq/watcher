require 'twilio-ruby'
require 'nexmo'
require_relative 'config'

class Sms

  def send(number, msg)
    number = "+#{number}" unless number[0] == '+'
    if Config.load['nexmo']
      client.send_message(from: 'Watcher', to: number, text: msg)
    else
      client.account.sms.messages.create body: msg, to: number, from: Config.load['twilio']['number']
    end
  end

private

  def client
    if Config.load['nexmo']
      @client ||= Nexmo::Client.new(key: Config.load['nexmo']['key'], secret: Config.load['nexmo']['secret'])
    else
      @client ||= Twilio::REST::Client.new Config.load['twilio']['account_sid'], Config.load['twilio']['auth_token']
    end
  end

end
