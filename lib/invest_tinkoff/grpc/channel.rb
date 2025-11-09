require 'grpc'

module InvestTinkoff
  module GRPC
    class Channel
      attr_reader :channel, :token

      def initialize(token:, sandbox: false)
        @token = token
        @sandbox = sandbox
        url = sandbox ? 'sandbox-invest-public-api.tinkoff.ru:443' : 'invest-public-api.tinkoff.ru:443'
        creds = ::GRPC::Core::ChannelCredentials.new
        @channel = ::GRPC::Core::Channel.new(url, {}, creds)
      end

      def metadata
        { 'authorization' => "Bearer #{@token}", 'x-app-name' => 'invest_tinkoff.ruby' }
      end
    end
  end
end
