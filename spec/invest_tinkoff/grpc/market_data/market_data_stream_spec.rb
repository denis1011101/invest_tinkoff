require "spec_helper"
require "timeout"

RSpec.describe InvestTinkoff::GRPC::MarketDataStream, :integration do
  let(:token) { ENV["TINKOFF_TOKEN"] || skip("TOKEN required") }
  let(:channel) { InvestTinkoff::GRPC::Channel.new(token: token, sandbox: false) }
  let(:stream) { described_class.new(channel: channel) }

  it "subscribes to order book stream and receives responses" do
    figi = "BBG000B9XRY4"
    depth = 10
    enum = stream.subscribe_order_books(figi: figi, depth: depth)

    response = nil
    Timeout.timeout(10) { response = enum.next }
    expect(response).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::MarketDataResponse)
    expect(response.orderbook).not_to be_nil
  rescue StopIteration
    skip("No streaming data received in timeframe")
  end
end
