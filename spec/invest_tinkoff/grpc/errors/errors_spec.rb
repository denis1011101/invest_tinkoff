require "spec_helper"

RSpec.describe InvestTinkoff::GRPC::ErrorMapper do
  let(:details) { "details" }

  it "maps NOT_FOUND to NotFound" do
    e = double("GRPC::BadStatus", code: GRPC::Core::StatusCodes::NOT_FOUND, details: details)
    expect(described_class.map(e)).to be_a(InvestTinkoff::GRPC::NotFound)
  end

  it "maps PERMISSION_DENIED to PermissionDenied" do
    e = double("GRPC::BadStatus", code: GRPC::Core::StatusCodes::PERMISSION_DENIED, details: details)
    expect(described_class.map(e)).to be_a(InvestTinkoff::GRPC::PermissionDenied)
  end

  it "maps UNAVAILABLE to Unavailable" do
    e = double("GRPC::BadStatus", code: GRPC::Core::StatusCodes::UNAVAILABLE, details: details)
    expect(described_class.map(e)).to be_a(InvestTinkoff::GRPC::Unavailable)
  end

  it "maps INTERNAL to Internal" do
    e = double("GRPC::BadStatus", code: GRPC::Core::StatusCodes::INTERNAL, details: details)
    expect(described_class.map(e)).to be_a(InvestTinkoff::GRPC::Internal)
  end

  it "maps unknown code to Error" do
    e = double("GRPC::BadStatus", code: 999, details: details)
    expect(described_class.map(e)).to be_a(InvestTinkoff::GRPC::Error)
  end
end
