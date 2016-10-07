require 'uri'

module Rpush
  module Daemon
    module Dispatcher
      class Http
        def initialize(app, delivery_class, _options = {})
          @app = app
          @delivery_class = delivery_class
          if defined?(Rails) and Rails.env.production? and defined?(Settings) and not Settings[:staging] and ENV['USE_HTTP_PROXY'] and ENV['USE_HTTP_PROXY'] == 'true'
            ENV['http_proxy'] = "http://#{Settings[:proxy_host]}:#{Settings[:proxy_port]}"
            ENV['HTTP_PROXY'] = ENV['http_proxy']
            proxy = URI "http://#{Settings[:proxy_host]}:#{Settings[:proxy_port]}"
            puts "Setting production http proxy to: #{ENV['http_proxy']}"
            @http = Net::HTTP::Persistent.new('rpush', proxy)
          else
            @http = Net::HTTP::Persistent.new('rpush')
          end
        end

        def dispatch(payload)
          @delivery_class.new(@app, @http, payload.notification, payload.batch).perform
        end

        def cleanup
          @http.shutdown
        end
      end
    end
  end
end
