require "spec_helper"

RSpec.describe RabidMQ do
  subject { described_class }

  it "has a version number" do
    expect(RabidMQ::VERSION).not_to be nil
  end

  describe 'interface' do
    it { is_expected.to respond_to :connect }
    it { is_expected.to respond_to :channel }
  end

  describe '#connect' do
    subject { described_class.connect }
    it { is_expected.to be_kind_of Bunny::Session }
    it { is_expected.to be_connected }
  end

  describe '#channel' do
    subject { described_class.channel }
    it { is_expected.to be_kind_of Bunny::Channel }
    it 'connection is the class level Bunny::Session' do
      expect(subject.connection).to eq described_class.connect
    end
  end

  describe '#topic_exchange' do
    subject { described_class.topic_exchange 'amq.topic' }
    it { is_expected.to be_kind_of Bunny::Exchange }
  end

  describe '#fanout_exchange' do
    subject { described_class.fanout_exchange 'amq.fanout' }
    it { is_expected.to be_kind_of Bunny::Exchange }
  end
end
