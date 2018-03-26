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
        attr_reader :amqp_queue, :amqp_exchange, :amqp_queue_name

        def amqp(queue, exchange, exclusive: false, routing_key: '#')
          # Set up an exchange
          setup_exchange(exchange)
          queue_name(queue)

          @routing_key = routing_key

          # Set up Queue
          setup_queue(queue, exclusive: exclusive)

          # Bind together
          amqp_queue.bind(amqp_exchange, routing_key: routing_key)
        end

        # Use this as a macro in including classes like
        # class MyClass
        #   include RabidMQ::Listener
        # end
        #
        def queue_name(name)
          @amqp_queue_name ||= name
        end

        def setup_queue(name, **options)
          @amqp_queue = RabidMQ.channel.queue(amqp_queue_name, **options)
        end

        # Use this as a macro in including classes like
        # class MyClass
        #   include RabidMQ::Listener
        #   exchange 'exchange.name'
        # end
        #
        def setup_exchange(topic, **options)
          @amqp_exchange = RabidMQ.topic_exchange topic, **options
        end

        alias_method :exchange, :setup_exchange

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
