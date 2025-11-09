require "spec_helper"

RSpec.describe "GRPC Users", :integration do
  let(:token) { ENV["TINKOFF_TOKEN"] || skip("TOKEN required") }
  let(:client) { InvestTinkoff::V2::Client.new(token: token) }

  it "fetches accounts" do
    resp = client.grpc_users.accounts
    expect(resp).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::GetAccountsResponse)
    expect(resp.accounts).to be_a(Array)
  end
end
