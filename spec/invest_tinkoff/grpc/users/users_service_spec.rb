require "spec_helper"

RSpec.describe InvestTinkoff::GRPC::UsersService, :integration do
  let(:token) { ENV["TINKOFF_TOKEN"] || skip("TOKEN required") }
  let(:channel) { InvestTinkoff::GRPC::Channel.new(token: token) }
  let(:invoker) { InvestTinkoff::GRPC::Invoker.new(channel: channel) }
  let(:service) { described_class.new(invoker: invoker) }

  it "fetches accounts" do
    resp = service.accounts
    expect(resp).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::GetAccountsResponse)
    expect(resp.accounts).to be_a(Array)
  end

  it "fetches margin attributes" do
    account_id = service.accounts.accounts.first.account_id
    resp = service.margin_attributes(account_id: account_id)
    expect(resp).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::GetMarginAttributesResponse)
  end
end
