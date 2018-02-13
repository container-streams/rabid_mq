module RabidMQ
  module Config
    class << self
      def load_config
        @config ||= default_config.merge custom_config
      rescue Errno::ENOENT, NameError => e
        puts "[WARN] #{e.message} in #{__FILE__}. Falling back to default config"
        default_config
      end

      def custom_config
        YAML.load(ERB.new(File.read(file_name)).result)[environment].symbolize_keys || {}
      end

      def environment
        return Rails.env if defined?(Rails)
        return ENV['RAILS_ENV'] || ENV['APPLICATION_ENV'] || 'default'
      end

      def default_config
        {
          :host           => "localhost",
          :port           => 5672,
          :ssl            => false,
          :vhost          => "/",
          :user           => "guest",
          :pass           => "guest",
          :heartbeat      => :server, # will use RabbitMQ setting
          :frame_max      => 131072,
          :auth_mechanism => "PLAIN",
          :recover_from_connection_close => true
        }
      end

      private
      def file_name
        if defined? ::Rails
          ::Rails.root.join('config/rabid_mq.yml')
        else
          'config/rabid_mq.yml'
        end
      end
    end
  end
end
