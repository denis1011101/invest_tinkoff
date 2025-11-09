require "spec_helper"

RSpec.describe "GRPC Operations", :integration do
  let(:token) { ENV["TINKOFF_TOKEN"] || skip("TOKEN required") }
  let(:client) { InvestTinkoff::V2::Client.new(token: token) }
  let(:account_id) { client.grpc_users.accounts.accounts.first.account_id }

  it "fetches portfolio" do
    resp = client.grpc_operations.portfolio(account_id: account_id)
    expect(resp).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::PortfolioResponse)
  end
end
