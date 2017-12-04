# Provides any including class with the ability to publish via RabidMQ
# Example:
# class MyClass
#   include RabidMQ::Publisher
# end
#
# MyClass.amqp_broadcast('some_topic', "Class Hello")
# instance = MyClass.new
# instance.amqp_broadcast('some_topic', "Instance Hello")
#

module RabidMQ
  module Publisher
    extend ActiveSupport::Concern

    included do
      def amqp_broadcast(*args, **options)
        self.class.amqp_broadcast *args, **options
      end

      alias_method :broadcast, :amqp_broadcast

      class << self
        def amqp_broadcast(topic, payload, routing_key: self.default_amqp_routing_key)
          exchange = topic_exchange(topic)
          exchange.publish(payload, routing_key: routing_key)
        rescue  => e
          Rails.logger.error e.message
        end

        alias_method :broadcast, :amqp_broadcast

        def default_amqp_routing_key
          self.name.underscore.gsub(/\//, '.')
        end

        # Provide a topic exchange on demand connected to the existing channel
        def topic_exchange(topic, **options)
          channel.topic(name_with_env(topic), **options)
        end

        # Provide fanout exchange
        def fanout_exchange(topic, **options)
          channel.fanout(name_with_env(topic), **options)
        end

        # Get a channel with the Bunny::Session
        def channel
          @channel ||= connect.create_channel
        rescue Bunny::ChannelAlreadyClosed => e
          @channel = nil
          channel
        end

        # Start a new connection
        def connect
          connection.tap do |c|
            c.start
          end
        end

        def name_with_env(name)
          return name unless defined?(::Rails)
          return name if name.match /\[(development|test|production|integration|pod)\]/
          name + "[#{Rails.env}]"
        end

        # Provide a new or existing Bunny::Session
        def connection
          @connection ||= Bunny.new RabidMQ::Config.load_config
        end

      end
    end
  end
end
