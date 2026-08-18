require_relative '../../../operations_services_pb'
require_relative '../call_options'

module InvestTinkoff
  module GRPC
    class OperationsService
      include InvestTinkoff::GRPC::CallOptions::Support

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
        @stub.get_portfolio(request, **call_options)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      # GetOperationsByCursor — операции по счёту за период, с пагинацией
      def operations_by_cursor(account_id:, from: nil, to: nil, cursor: nil, limit: nil)
        attrs = { account_id: account_id }
        attrs[:from] = to_timestamp(from) if from
        attrs[:to] = to_timestamp(to) if to
        attrs[:cursor] = cursor if cursor
        attrs[:limit] = limit if limit
        request = Tinkoff::Public::Invest::Api::Contract::V1::GetOperationsByCursorRequest.new(**attrs)
        @stub.get_operations_by_cursor(request, **call_options)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      private

      def to_timestamp(time)
        Google::Protobuf::Timestamp.new(seconds: time.to_i, nanos: 0)
      end
    end
  end
end
