module InvestTinkoff
  module GRPC
    class Invoker
      attr_reader :channel

      def initialize(channel:)
        @channel = channel
      end
    end
  end
end
