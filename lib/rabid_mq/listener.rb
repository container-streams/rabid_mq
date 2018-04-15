# Provides including class with ability to subscribe and react to events that
# arrive via RabidMQ
# Example:
# class MyClass
#   include RabidMQ::Listener
#
#   amqp 'queue_name', 'exchange.name', exclusive: false, routing_key: 'some.routing.*.key'
#
#   subscribe do |info, meta, data|
#     # code to do on message receipt
#   end
# end
#

module RabidMQ
  module Listener
    extend ::ActiveSupport::Concern

    included do
      class << self
        attr_reader :amqp_queue, :amqp_exchange, :routing_key

        def amqp(queue, exchange, exclusive: false, routing_key: '#', include_environment_name: true)
          self.queue_name queue, exclusive: exclusive, include_environment_name: include_environment_name
          self.exchange(exchange, include_environment_name: include_environment_name)
          @routing_key = routing_key
          amqp_queue.bind(amqp_exchange, routing_key: routing_key)
        end

        # Use this as a macro in including classes like
        # class MyClass
        #   include RabidMQ::Listener
        #   queue_name 'some.queue_name', exclusive: true
        # end
        #
        def queue_name(name, include_environment_name: true, **options)
          resolved_name = include_environment_name ? name_with_env(name) : name
          @amqp_queue = RabidMQ.channel.queue(resolved_name, **options)
        end

        # Use this as a macro in including classes like
        # class MyClass
        #   include RabidMQ::Listener
        #   exchange 'exchange.name'
        # end
        #
        def exchange(topic, include_environment_name: true, **options)
          topic_name = include_environment_name ? name_with_env(topic) : topic
          @amqp_exchange = RabidMQ.topic_exchange topic_name, **options
        end

        def bind(exchange=amqp_exchange, routing_key: @routing_key, **options)
          amqp_queue.bind(exchange, routing_key: routing_key, **options)
        end

        delegate :subscribe, to: :amqp_queue
        delegate :channel, to: ::RabidMQ
        delegate :queue, to: :channel
        delegate :name_with_env, to: ::RabidMQ

        def amqp_connection
          amqp_exchange.channel.connection
        end
      end
    end
  end
end
