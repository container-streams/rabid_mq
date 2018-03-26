require "spec_helper"

RSpec.describe RabidMQ::Listener do
  class RabidMQ::ListenerSpecClass
    include RabidMQ::Listener

    amqp 'tests', 'tests', routing_key: "tests.tests"

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

  describe "name_with_env" do
    let(:exchange_name) { 'test.exchange.name' }
    subject { test_class.name_with_env(exchange_name) }
    context 'when there is no rails' do
      it { is_expected.to eq exchange_name }
    end

    context 'when rails is defined' do
      let(:ideal) { "test.exchange.name[development]" }

      before do
        Rails = Hashie::Mash.new(env: 'development')
      end

      it { is_expected.to eq ideal }

      context 'if the env is already included' do
        let(:exchange_name) { "test.exchange.name[development]" }
        it 'matches the ideal' do
          is_expected.to eq ideal
        end
      end
    end
  end
end
