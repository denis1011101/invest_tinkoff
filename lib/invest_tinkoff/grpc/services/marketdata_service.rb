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

      # Свечи по figi (устар.) или по instrument_id (figi/uid — рекомендуется, обязателен
      # для индексов, у которых нет торгуемого figi). Если задан instrument_id — он приоритетен.
      def candles(from:, to:, interval:, figi: nil, instrument_id: nil)
        raise ArgumentError, 'either figi or instrument_id is required' if figi.nil? && instrument_id.nil?

        attrs = { from: to_ts(from), to: to_ts(to), interval: interval }
        attrs[:figi] = figi if figi
        attrs[:instrument_id] = instrument_id if instrument_id
        req = ::Tinkoff::Public::Invest::Api::Contract::V1::GetCandlesRequest.new(**attrs)
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
