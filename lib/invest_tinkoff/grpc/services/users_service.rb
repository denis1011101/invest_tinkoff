require_relative '../../../users_services_pb'
require_relative '../call_options'

module InvestTinkoff
  module GRPC
    class UsersService
      include InvestTinkoff::GRPC::CallOptions::Support

      def initialize(invoker:)
        @invoker = invoker
        @stub = Tinkoff::Public::Invest::Api::Contract::V1::UsersService::Stub.new(
          nil,
          nil,
          channel_override: @invoker.channel.channel
        )
      end

      def accounts
        request = Tinkoff::Public::Invest::Api::Contract::V1::GetAccountsRequest.new
        @stub.get_accounts(request, **call_options)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end
    end
  end
end
