require 'faraday'

class Checker

  def status(url)
    Timeout.timeout(75) do
      url = "http://#{url}" unless url =~ /^http/
      status = conn(url).get.status
      if status == 522 || status == 504 # 522 cloudflare timeout 504 gateway timeout
        'timeout'
      else
        status
      end
    end
  rescue Timeout::Error
    'timeout'
  rescue Faraday::SSLError
    'sslerror'
  rescue Faraday::ConnectionFailed
    'noconn'
  rescue
    "exception: #{$!.class} #{$!.message}"
  end

private

  def conn(url)
    conn = Faraday.new(url: url) do |c|
      c.adapter Faraday.default_adapter
    end
  end

end
