require_relative '../../../marketdata_services_pb'
require 'google/protobuf/timestamp_pb'

module InvestTinkoff
  module GRPC
    class MarketDataService
      def initialize(invoker:)
        @invoker = invoker
        @stub = ::Tinkoff::Public::Invest::Api::Contract::V1::MarketDataService::Stub.new(
          nil, nil, channel_override: @invoker.channel.channel
        )
      end

      def last_prices(figis:)
        req = ::Tinkoff::Public::Invest::Api::Contract::V1::GetLastPricesRequest.new(figi: figis)
        @stub.get_last_prices(req, metadata: @invoker.channel.metadata)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      def candles(figi:, from:, to:, interval:)
        req = ::Tinkoff::Public::Invest::Api::Contract::V1::GetCandlesRequest.new(
          figi: figi,
          from: to_ts(from),
          to: to_ts(to),
          interval: interval
        )
        @stub.get_candles(req, metadata: @invoker.channel.metadata)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      private

      def to_ts(time)
        Google::Protobuf::Timestamp.new(seconds: time.to_i, nanos: 0)
      end
    end
  end
end
