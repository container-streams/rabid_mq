require "spec_helper"

RSpec.describe RabidMQ::Listener do
  class RabidMQ::ListenerSpecClass
    include RabidMQ::Listener

    queue_name 'tests'
    exchange 'tests'

    # This is just here to ensure we don't get errors doing this. It is just about
    # impossible to test (AFAIK) since the RabidMQ handling is asynchronous
    subscribe do |info, meta, data|
      puts data
      Rails.logger.info("RabidMQ subscribe works. Received: #{data}")
    end
  end

  let(:test_class) { RabidMQ::ListenerSpecClass }
  subject { test_class }

  describe 'interface' do
    it { is_expected.to respond_to :amqp_exchange }
    it { is_expected.to respond_to :amqp_queue }
    it { is_expected.to respond_to :amqp_connection }
  end

  describe 'amqp_queue' do
    subject { test_class.amqp_queue }
    it { is_expected.to be_kind_of Bunny::Queue }
  end

  describe '#amqp_exchange' do
    subject { test_class.amqp_exchange }
    it { is_expected.to be_kind_of Bunny::Exchange }
    it 'has the correct name' do
      expect(subject.name).to eq 'tests'
    end
  end

  describe 'amqp_connection' do
    subject { test_class.amqp_connection }
    it { is_expected.to be_kind_of Bunny::Session }
    it { is_expected.to be_connected }
  end
end
