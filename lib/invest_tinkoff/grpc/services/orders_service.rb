require_relative '../../../orders_services_pb'

module InvestTinkoff
  module GRPC
    class OrdersService
      def initialize(invoker:)
        @invoker = invoker
        @stub = ::Tinkoff::Public::Invest::Api::Contract::V1::OrdersService::Stub.new(
          nil, nil, channel_override: @invoker.channel.channel
        )
      end

      def post_order(account_id:, figi:, quantity:, price:, direction:, order_type:, order_id:)
        req = ::Tinkoff::Public::Invest::Api::Contract::V1::PostOrderRequest.new(
          account_id: account_id,
          figi: figi,
          quantity: quantity,
          price: to_q(price),
          direction: direction,
          order_type: order_type,
          order_id: order_id
        )
        @stub.post_order(req, metadata: @invoker.channel.metadata)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      private

      def to_q(value)
        units = value.to_i
        nano = ((value - units) * 1_000_000_000).round
        ::Tinkoff::Public::Invest::Api::Contract::V1::Quotation.new(units: units, nano: nano)
      end
    end
  end
end
