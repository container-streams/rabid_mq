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

        delegate :topic_exchange, to: RabidMQ

        def default_amqp_routing_key
          self.name.underscore.gsub(/\//, '.')
        end

      end
    end
  end
end
