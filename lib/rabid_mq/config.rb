module RabidMQ
  module Config
    class << self
      def load_config
        @config ||= YAML.load(ERB.new(File.read(file_name)).result)[Rails.env]
      rescue Errno::ENOENT, NameError => e
        puts "[WARN] #{e.message} in #{__FILE__}. Falling back to default config"
        default_config
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
          :auth_mechanism => "PLAIN"
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
