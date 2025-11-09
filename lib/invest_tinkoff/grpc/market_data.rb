require_relative '../invoker'
require 'tinkoff/public/invest/api/contract/v1/marketdata_pb'
require 'tinkoff/public/invest/api/contract/v1/marketdata_services_pb'

module InvestTinkoff
  module GRPC
    class MarketDataService
      def initialize(invoker:)
        @invoker = invoker
      end

      def order_book(instrument_id:, depth:, instrument_id_type: :INSTRUMENT_ID_TYPE_FIGI)
        req = Tinkoff::Public::Invest::Api::Contract::V1::GetOrderBookRequest.new(
          instrument_id: instrument_id,
          depth: depth,
          instrument_id_type: instrument_id_type
        )
        @invoker.call(
          Tinkoff::Public::Invest::Api::Contract::V1::MarketDataService::Stub,
          :get_order_book,
          req
        )
      end
    end
  end
end
