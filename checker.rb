require 'faraday'

class Checker

  def ping(url)
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

  # receives a list of sites, previous statuses and returns screen_output and msg (for email and sms)
  def report(sites, statuses, options = {})
    local = options[:local]
    server = options[:server]
    msg = ''
    screen_output = ''

    for site in sites
      next if site['disabled']

      status = statuses[site['name']]

      time = Benchmark.realtime do
        status['result'] = ping(site['url'])
        # puts site['name']
        # puts status['result']
      end

      if Status.bad(status) && status['prev_result'] == status['result'] && !status['reported'] && status['result'] != 'timeout'
        if !local || (local && status['result'] != 'noconn') # laptop without connectivity
          status['reported'] = true
          msg += "#{site['name']} (#{status['result']}) | "
        end
      end

      screen_output += "#{site['name']}: "
      if Status.bad(status)
        screen_output += "DOWN (#{status['result']})\n".red
        # print "#{site['name']}: "
        # if !local || (local && !['noconn', 'sslerror'].include?(status['result']))
        #   puts (server ? "#{site['name']} down (#{status['result']})" : "DOWN (#{status['result']})".red)
        # end
      else#if !local
        screen_output += "OK".green + " (#{time.round(2)}s)\n"
        status['reported'] = false
      end

      #status['reported'] = false unless Status.bad(status)
    end

    #puts "MSG"
    #puts msg

    [screen_output, msg == '' ? nil : msg.strip.chomp('|')]
  end

private

  def conn(url)
    conn = Faraday.new(url: url) do |c|
      c.adapter Faraday.default_adapter
    end
  end

end
