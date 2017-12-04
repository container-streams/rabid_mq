require 'bunny'
require 'yaml'
require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'rabid_mq/version'
require 'rabid_mq/railtie' if defined?(::Rails)
require 'rabid_mq/config'
require 'rabid_mq/listener'
require 'rabid_mq/publisher'

STDOUT.sync = true
# Module to abstract the boilerplate of connecting to rabbitMQ
# This will also abstract how the credentials are supplied etc
module RabidMQ
  class << self

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
      connection.create_channel
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
      Bunny.new RabidMQ::Config.load_config
    end
  end
end
