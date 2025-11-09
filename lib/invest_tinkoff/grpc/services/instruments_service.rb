require_relative '../../../instruments_services_pb'

module InvestTinkoff
  module GRPC
    class InstrumentsService
      def initialize(invoker:)
        @invoker = invoker
        @stub = ::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentsService::Stub.new(
          nil, nil, channel_override: @invoker.channel.channel
        )
      end

      # Поиск инструмента по свободному запросу (тикер, FIGI, ISIN, UID).
      # Использует FindInstrument gRPC метод.
      def find_instrument(query:)
        req = ::Tinkoff::Public::Invest::Api::Contract::V1::FindInstrumentRequest.new(query: query)
        @stub.find_instrument(req, metadata: @invoker.channel.metadata)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      # Удобный поиск акции по тикеру с optional class_code (как раньше).
      def share_by_ticker(ticker:, class_code: nil)
        req = ::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentRequest.new(
          id_type: ::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentIdType::INSTRUMENT_ID_TYPE_TICKER,
          class_code: class_code,
          id: ticker
        )
        @stub.share_by(req, metadata: @invoker.channel.metadata)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end
    end
  end
end
