require "spec_helper"

RSpec.describe InvestTinkoff::GRPC::Invoker do
  let(:channel) { double("Channel", channel: :grpc_channel, metadata: {}) }
  let(:stub_class) { Class.new { def initialize(_); end; def test_rpc(*); :ok; end } }
  let(:invoker) { described_class.new(channel: channel) }

  it "calls stub method" do
    result = invoker.call(stub_class, :test_rpc, :request)
    expect(result).to eq(:ok)
  end

  it "caches stubs" do
    stub1 = invoker.send(:instance_variable_get, :@stubs)[stub_class]
    invoker.call(stub_class, :test_rpc, :request)
    stub2 = invoker.send(:instance_variable_get, :@stubs)[stub_class]
    expect(stub1).to eq(stub2)
  end

  it "maps grpc errors" do
    error_stub = Class.new { def initialize(_); end; def test_rpc(*); raise GRPC::BadStatus.new(1, "fail"); end }
    allow(InvestTinkoff::GRPC::ErrorMapper).to receive(:map).and_return(StandardError.new("mapped"))
    expect { invoker.call(error_stub, :test_rpc, :request) }.to raise_error(StandardError, "mapped")
  end

  it "retries on retryable errors" do
    attempts = 0
    retryable_code = GRPC::Core::StatusCodes::UNAVAILABLE
    error_stub = Class.new do
      define_method(:initialize) { |_| }
      define_method(:test_rpc) do |*|
        attempts += 1
        raise GRPC::BadStatus.new(retryable_code, "fail") if attempts < 3
        :ok
      end
    end
    allow(InvestTinkoff::GRPC::ErrorMapper).to receive(:map).and_call_original
    result = invoker.call(error_stub, :test_rpc, :request, retries: 2, retryable: [retryable_code])
    expect(result).to eq(:ok)
    expect(attempts).to eq(3)
  end

  it "returns nil deadline if timeout not set" do
    expect(invoker.send(:deadline, nil)).to be_nil
  end

  it "returns deadline if timeout set" do
    t = Time.now
    allow(Time).to receive(:now).and_return(t)
    expect(invoker.send(:deadline, 10)).to eq(t + 10)
  end
end
