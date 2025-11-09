require "spec_helper"

RSpec.describe InvestTinkoff::GRPC::MarketDataService, :integration do
  let(:token) { ENV["TINKOFF_TOKEN"] || skip("TOKEN required") }
  let(:channel) { InvestTinkoff::GRPC::Channel.new(token: token) }
  let(:invoker) { InvestTinkoff::GRPC::Invoker.new(channel: channel) }
  let(:service) { described_class.new(invoker: invoker) }

  it "fetches order book" do
    resp = service.order_book(instrument_id: "BBG000B9XRY4", depth: 10)
    expect(resp).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::GetOrderBookResponse)
    expect(resp.orderbook).not_to be_nil
  end
end
