require_relative '../../../instruments_pb'
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

      # Основная информация об инструменте (любого типа) через GetInstrumentBy.
      # id_type: :figi | :uid | :ticker | :position_uid (или готовый enum InstrumentIdType).
      # При id_type == :ticker обязателен class_code.
      # Возвращает Instrument (resp.instrument) либо nil, если инструмент не найден.
      def get_instrument_by(id_type, id, class_code: nil)
        resolved_type = instrument_id_type(id_type)
        if resolved_type == ::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentIdType::INSTRUMENT_ID_TYPE_TICKER &&
           (class_code.nil? || class_code.to_s.empty?)
          raise ArgumentError, 'class_code is required when id_type is :ticker'
        end

        req = ::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentRequest.new(
          id_type: resolved_type,
          class_code: class_code,
          id: id.to_s
        )
        resp = @stub.get_instrument_by(req, metadata: @invoker.channel.metadata)
        resp.respond_to?(:instrument) ? resp.instrument : resp
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      # Индикативные инструменты (индексы, товары и т.п.) через Indicatives.
      # Возвращает массив инструментов (resp.instruments) с полями uid/figi/ticker/name.
      def indicatives
        req = ::Tinkoff::Public::Invest::Api::Contract::V1::IndicativesRequest.new
        resp = @stub.indicatives(req, metadata: @invoker.channel.metadata)
        resp.respond_to?(:instruments) ? resp.instruments : []
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      # Возвращает список акций (Shares) через gRPC
      def shares(instrument_status: nil)
        status = instrument_status ||
                 (::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentStatus::INSTRUMENT_STATUS_BASE rescue 1)

        req_klass =
          if defined?(::Tinkoff::Public::Invest::Api::Contract::V1::SharesRequest)
            ::Tinkoff::Public::Invest::Api::Contract::V1::SharesRequest
          elsif defined?(::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentsRequest)
            ::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentsRequest
          else
            nil
          end
        raise NameError, 'SharesRequest message not available in loaded protos' unless req_klass

        req = req_klass.new(instrument_status: status)
        @stub.shares(req, metadata: @invoker.channel.metadata)
      rescue ::GRPC::BadStatus => e
        raise InvestTinkoff::GRPC::ErrorMapper.map(e)
      end

      private

      # Приводит символ/строку к значению InstrumentIdType.
      # Неизвестный тип — это ошибка вызывающего кода, а не «unspecified».
      def instrument_id_type(id_type)
        return id_type unless id_type.is_a?(Symbol) || id_type.is_a?(String)

        enum = ::Tinkoff::Public::Invest::Api::Contract::V1::InstrumentIdType
        case id_type.to_s.downcase
        when 'figi' then enum::INSTRUMENT_ID_TYPE_FIGI
        when 'uid' then enum::INSTRUMENT_ID_TYPE_UID
        when 'ticker' then enum::INSTRUMENT_ID_TYPE_TICKER
        when 'position_uid' then enum::INSTRUMENT_ID_TYPE_POSITION_UID
        else raise ArgumentError, "unknown id_type: #{id_type.inspect} (expected :figi/:uid/:ticker/:position_uid)"
        end
      end
    end
  end
end
