module Rpush
  module Daemon
    module Apns
      extend ServiceConfigMethods

      if defined?(Rails) and Rails.env.production? and defined?(Settings) and not Settings[:staging] and ENV['USE_CUSTOM_APNS_HOSTS'] and ENV['USE_CUSTOM_APNS_HOSTS'] == 'true'
        HOSTS = {
          production: ['rlm-brevprx-vip', 2195],
          development: ['rlm-brevprx-vip', 2196], # deprecated
          sandbox: ['rlm-brevprx-vip', 2196]
        }
        puts("Using custom APNS hosts: #{HOSTS.inspect}")
      else
        HOSTS = {
          production: ['gateway.push.apple.com', 2195],
          development: ['gateway.sandbox.push.apple.com', 2195], # deprecated
          sandbox: ['gateway.sandbox.push.apple.com', 2195]
        }
        puts("Using APNS hosts: #{HOSTS.inspect}")
      end

      batch_deliveries true
      dispatcher :apns_tcp, host: proc { |app| HOSTS[app.environment.to_sym] }
      loops Rpush::Daemon::Apns::FeedbackReceiver, if: -> { Rpush.config.apns.feedback_receiver.enabled && !Rpush.config.push }
    end
  end
end
