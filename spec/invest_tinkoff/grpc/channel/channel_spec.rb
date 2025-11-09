require "spec_helper"

RSpec.describe InvestTinkoff::GRPC::Channel do
  let(:token) { "test-token" }

  it "sets prod target by default" do
    ch = described_class.new(token: token)
    expect(ch.instance_variable_get(:@target)).to eq(InvestTinkoff::GRPC::PROD_TARGET)
  end

  it "sets sandbox target if sandbox: true" do
    ch = described_class.new(token: token, sandbox: true)
    expect(ch.instance_variable_get(:@target)).to eq(InvestTinkoff::GRPC::SANDBOX_TARGET)
  end

  it "returns correct metadata" do
    ch = described_class.new(token: token)
    meta = ch.metadata("foo" => "bar")
    expect(meta).to include("authorization" => "Bearer test-token", "x-app-name" => "invest_tinkoff-ruby", "foo" => "bar")
  end

  it "creates a GRPC channel" do
    ch = described_class.new(token: token)
    expect(ch.channel).to be_a(GRPC::Core::Channel)
  end
end
