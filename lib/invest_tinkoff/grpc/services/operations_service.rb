require_relative '../../../operations_services_pb'

module InvestTinkoff
  module GRPC
    class OperationsService
      def initialize(invoker:)
        @invoker = invoker
        @stub = Tinkoff::Public::Invest::Api::Contract::V1::OperationsService::Stub.new(
          nil,
          nil,
          channel_override: @invoker.channel.channel
        )
      end

      def portfolio(account_id:)
        request = Tinkoff::Public::Invest::Api::Contract::V1::PortfolioRequest.new(account_id: account_id)
        @stub.get_portfolio(request, metadata: @invoker.channel.metadata)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end
    end
  end
end
