# frozen_string_literal: true

module InvestTinkoff
  module GRPC
    # Опции gRPC-вызова: метаданные канала плюс абсолютный дедлайн.
    #
    # Сам по себе gRPC время RPC не ограничивает, а половина обрывов канала до
    # брокера выглядит как живой ESTABLISHED-сокет, в который уже никогда ничего
    # не придёт. 2026-08-18 прогон стратегии в боте так и завис: 2ч45м на вызове
    # без единой строки в логе, и всё это время cron с flock -n молча пропускал
    # следующие запуски. Дедлайн превращает такое зависание в обычную ошибку,
    # которую вызывающий код уже умеет обрабатывать.
    #
    # Дедлайн считается на каждый вызов, а не на канал: один прогон стратегии
    # делает десятки RPC, и общего бюджета у него нет.
    module CallOptions
      DEFAULT_TIMEOUT_SECONDS = 30.0
      ENV_KEY = 'INVEST_TINKOFF_GRPC_TIMEOUT'

      module_function

      # Секунды до дедлайна либо nil, если дедлайн отключён.
      #
      # Отключение возможно только явным INVEST_TINKOFF_GRPC_TIMEOUT=0; мусор в
      # переменной откатывается к дефолту, а не снимает защиту молча.
      def timeout_seconds(env = ENV)
        raw = env[ENV_KEY].to_s.strip
        return DEFAULT_TIMEOUT_SECONDS if raw.empty?

        value = Float(raw, exception: false)
        return DEFAULT_TIMEOUT_SECONDS if value.nil?
        return nil if value <= 0

        value
      end

      def build(channel, timeout: timeout_seconds, now: Time.now)
        options = { metadata: channel.metadata }
        options[:deadline] = now + timeout if timeout
        options
      end

      # Подмешивается в сервисы: у всех одинаковый @invoker, отличается только стаб.
      module Support
        private

        def call_options
          CallOptions.build(@invoker.channel)
        end
      end
    end
  end
end
