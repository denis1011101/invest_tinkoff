require "spec_helper"

RSpec.describe "GRPC Operations", :integration do
  let(:token) { ENV["TINKOFF_TOKEN"] || skip("TOKEN required") }
  let(:client) { InvestTinkoff::V2::Client.new(token: token) }
  let(:account_id) { client.grpc_users.accounts.accounts.first.id }

  it "fetches portfolio" do
    resp = client.grpc_operations.portfolio(account_id: account_id)
    expect(resp).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::PortfolioResponse)
  end

  it "fetches operations by cursor for a period" do
    resp = client.grpc_operations.operations_by_cursor(
      account_id: account_id,
      from: Time.now - (2 * 24 * 3600),
      to: Time.now
    )
    expect(resp).to be_a(Tinkoff::Public::Invest::Api::Contract::V1::GetOperationsByCursorResponse)
    expect(resp.items).to respond_to(:each)
    expect(resp).to respond_to(:has_next)
  end
end
