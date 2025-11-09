require_relative '../invoker'
require 'tinkoff/public/invest/api/contract/v1/users_pb'
require 'tinkoff/public/invest/api/contract/v1/users_services_pb'

module InvestTinkoff
  module GRPC
    module V1
      Api = ::Tinkoff::Public::Invest::Api::Contract::V1 unless const_defined?(:Api)
    end

    class UsersService
      def initialize(invoker:)
        @invoker = invoker
      end

      def accounts
        req = V1::Api::GetAccountsRequest.new
        @invoker.call(V1::Api::UsersService::Stub, :get_accounts, req)
      end

      def margin_attributes(account_id:)
        req = V1::Api::GetMarginAttributesRequest.new(account_id: account_id)
        @invoker.call(V1::Api::UsersService::Stub, :get_margin_attributes, req)
      end
    end
  end
end
