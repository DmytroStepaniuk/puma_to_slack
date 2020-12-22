#
# First, u need configure phased restart.
# https://github.com/puma/puma/blob/master/docs/restart.md#phased-restart
#
directory '...'
rackup '.../config.ru'
environment 'production'

pidfile '...'
state_path '...'
stdout_redirect '...', true

threads 2,2

bind 'tcp://0.0.0.0:3000'
workers 2

prune_bundler

on_restart do
  puts 'Refreshing Gemfile'
  ENV['BUNDLE_GEMFILE'] = '/srv/{{ projectName }}/{{ backendPart }}/current/Gemfile'
end

#
# Configure Slack 
#

tag "Your awesome backend name goes here"

def print_worker_index_of index
  worker_index = ""

  (index + 1).to_s.split('').each do |number|
    case number
    when "1"
      worker_index = worker_index.concat(":one:")
    when "2"
      worker_index = worker_index.concat(":two:")
    when "3"
      worker_index = worker_index.concat(":three:")
    when "4"
      worker_index = worker_index.concat(":four:")
    when "5"
      worker_index = worker_index.concat(":five:")
    when "6"
      worker_index = worker_index.concat(":six:")
    when "7"
      worker_index = worker_index.concat(":seven:")
    when "8"
      worker_index = worker_index.concat(":eight:")
    when "9"
      worker_index = worker_index.concat(":nine:")
    when "0"
      worker_index = worker_index.concat(":zero:")
    end
  end

  return worker_index
end

#
# https://github.com/puma/puma/blob/a6dcb506f285496140bf5802414ea83801b0eb38/docs/signals.md#send-usr2
#
on_worker_shutdown do |index|
  begin
    require 'dotenv'

    if webhook_url = ( ENV['SLACK_SPEAKER__WEBHOOK_URL_FOR_PUMA'] || Dotenv.load.fetch('SLACK_SPEAKER__WEBHOOK_URL_FOR_PUMA') )
      require "uri"
      require "net/http"
      require "json"

      data = { text: "#{ print_worker_index_of(index) } :point_right: `#{ @options[:workers] }` :dancer:" }

      url = URI(webhook_url)

      https = Net::HTTP.new(url.host, url.port);
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = ["application/json", "text/plain"]
      request.body = JSON.generate(data)

      response = https.request(request)
      puts "[slack api] => #{ response.read_body }"
    end
  rescue => e
    puts "[slack api] => #{ e.message }"
  end
end


#
# https://github.com/puma/puma/blob/a6dcb506f285496140bf5802414ea83801b0eb38/docs/signals.md#send-usr2
#
on_worker_boot do |index|
  begin
    require 'dotenv'

    if webhook_url = ( ENV['SLACK_SPEAKER__WEBHOOK_URL_FOR_PUMA'] || Dotenv.load.fetch('SLACK_SPEAKER__WEBHOOK_URL_FOR_PUMA') )
      require "uri"
      require "net/http"
      require "json"

      data = { text: "#{ print_worker_index_of(index) } :point_right: `#{ @options[:workers] }` :ballot_box_with_check:" }

      url = URI(webhook_url)

      https = Net::HTTP.new(url.host, url.port);
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = ["application/json", "text/plain"]
      request.body = JSON.generate(data)

      response = https.request(request)
      puts "[slack api] => #{ response.read_body }"
    end
  rescue => e
    puts "[slack api] => #{ e.message }"
  end
end
