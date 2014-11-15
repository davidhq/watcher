require 'twilio-ruby'
require_relative 'config'

class Sms

  def send(number, message)
    number = "+#{number}" unless number[0] == '+'
    client.account.sms.messages.create body: message, to: number, from: Config.load['twilio']['number']
  end

private

  def client
    @client ||= Twilio::REST::Client.new Config.load['twilio']['account_sid'], Config.load['twilio']['auth_token']
  end

end
