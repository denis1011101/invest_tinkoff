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

      # GetOperationsByCursor — операции по счёту за период, с пагинацией
      def operations_by_cursor(account_id:, from: nil, to: nil, instrument_id: nil, cursor: nil, limit: nil)
        attrs = { account_id: account_id }
        attrs[:from] = to_timestamp(from) if from
        attrs[:to] = to_timestamp(to) if to
        attrs[:instrument_id] = instrument_id if instrument_id
        attrs[:cursor] = cursor if cursor
        attrs[:limit] = limit if limit
        request = Tinkoff::Public::Invest::Api::Contract::V1::GetOperationsByCursorRequest.new(**attrs)
        @stub.get_operations_by_cursor(request, metadata: @invoker.channel.metadata)
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
