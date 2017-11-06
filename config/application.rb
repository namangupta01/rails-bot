require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsBot
	class Application < Rails::Application
		# Settings in config/environments/* take precedence over those specified here.
		# Application configuration should go into files in config/initializers
		# -- all .rb files in that directory are automatically loaded.

		# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
		# Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
		# config.time_zone = 'Central Time (US & Canada)'

		# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
		# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
		# config.i18n.default_locale = :de

		# Do not swallow errors in after_commit/after_rollback callbacks.
		config.active_record.raise_in_transactional_callbacks = true
			rc = JSON.parse HTTP.post("https://slack.com/api/rtm.start", params: {token: ENV['rails_bot_slack']})
			puts rc
			url = rc['url']
			EM.run do
					ws = Faye::WebSocket::Client.new(url)
					ws.on :open do |event|
							p [:open]
					end
					ws.on :message do |event|
							data = JSON.parse(event.data) if event && event.data
							p [:message, data]
							if data && data['type'] == 'message' && data['text'] == 'hello'
								ws.send({ type: 'message', text: "Hey<@#{data['user']}>", channel: data['channel'] }.to_json)
							end
					end
					ws.on :close do |event|
						p [:close, event.code, event.reason]
						ws = nil
					end
			end
	end
end
