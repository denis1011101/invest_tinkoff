require "spec_helper"

RSpec.describe InvestTinkoff::GRPC::OrdersService, :integration do
  let(:token) { ENV["TINKOFF_TOKEN"] || skip("TOKEN required") }
  let(:channel) { InvestTinkoff::GRPC::Channel.new(token: token) }
  let(:invoker) { InvestTinkoff::GRPC::Invoker.new(channel: channel) }
  let(:service) { described_class.new(invoker: invoker) }
  let(:users) { InvestTinkoff::GRPC::UsersService.new(invoker: invoker) }

  it "fetches active orders" do
    account_id = users.accounts.accounts.first.id
    resp = service.get_orders(account_id: account_id)
    expect(resp).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::GetOrdersResponse)
    expect(resp.orders).to respond_to(:each)
  end
end
