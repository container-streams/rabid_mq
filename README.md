# RabidMQ

Create Producers and Consumers for RabbitMQ based system with ease

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rabid_mq'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install rabid_mq
```

## Configuration

To configure simply add a yaml file `config/rabid_mq.yml` to your project and adjust the settings to match your requirements. These options are used verbatim to initialize `bunny` so any option supported by bunny is also supported in the rabid_mq config.

```yaml
# config/rabid_mq.yml

default: &default
  host: localhost
  port: 5672
  ssl: false
  vhost: "/"
  user: guest
  pass: guest
  heartbeat: server
  frame_max: 131072
  auth_mechanism: PLAIN

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default
```

## Usage

### AMQP Producer

To create a RabbitMQ "Producer" you can include the RabidMQ::Publisher concern in your producer class

`app/models/my_class.rb`

```ruby
class MyClass
  include RabidMQ::Publisher

  # code ...
end
```

`app/controllers/some_controller.rb`

```ruby
class SomeController < ApplicationController
  def create
    # code ...
    MyClass.broadcast('some.amqp.topic', "Hello RabbitMQ")

    #  OR

    # if you already have a `broadcast` method you can use the method `amqp_broadcast`
    MyClass.amqp_broadcast('some.amqp.topic', "Hello RabbitMQ")

    # OR

    # IF you have an instance of MyClass
    my_class_instance.broadcast('some.amqp.topic', "Hellow RabbitMQ from an instance")

    # code ...
  end
end
```

### Consumer

`app/models/my_class`

```ruby
class MyClass
  include RabidMQ::Listener

  amqp 'some_queue_name', 'some.exchange.name', exclusive: false, routing_key: 'some.*.key.*.definition'

  # OR (for finer grained control with more options)
  # queue_name 'name', **options
  # exchange 'name', **options

  subscribe do |info, meta, data|
    # Do your logic with the data here
  end

  # Or (for finer control on the exchange binding) you can pass in an explicitly created
  # Bunny::Exchange object with options
  # bind(exchange, **options).subscribe do |info, meta, data|
  #  # code ...
  # end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/[USERNAME]/rabid_mq>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
