class Status

  STATUS_FILE = 'statuses.json'

  def self.bad(status)
    ![200, 302].include?(status['result'])
  end

  # reads saved status from file
  # - adds prev_status field for each site which equals to current status at the time of reading the file
  def self.read(sites)
    statuses = {}
    status_file = File.join(File.dirname(__FILE__), STATUS_FILE)

    if File.exists?(status_file)
      statuses = JSON.parse(File.read(status_file))
      for site in statuses.keys
        if sites.find { |s| s['name'] == site }
          statuses[site]['prev_result'] = statuses[site]['result']
        else
          statuses.delete site
        end
      end
    end

    for site in sites
      statuses[site['name']] = {} unless statuses[site['name']]
    end

    statuses
  end

  def self.write(statuses)
    status_file = File.join(File.dirname(__FILE__), STATUS_FILE)
    File.open(status_file, 'w') { |file| file.puts statuses.to_json }
  end

end
