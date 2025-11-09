# frozen_string_literal: true

require 'httparty'

# Base class for Tinkoff API REST client
module InvestTinkoff
  class ClientBase
    include HTTParty

    def initialize token:, broker_account_id: nil, logger: nil, sandbox: false
      @token = token
      @broker_account_id = broker_account_id
      @logger = logger
      @sandbox = sandbox
    end

    # --- gRPC lazy init and accessors ---
    def grpc_init!
      return if defined?(@grpc_invoker) && @grpc_invoker
      raise 'gRPC support not loaded' unless defined?(InvestTinkoff::GRPC::Channel)

      ch = InvestTinkoff::GRPC::Channel.new(token: @token, sandbox: @sandbox)
      @grpc_invoker = InvestTinkoff::GRPC::Invoker.new(channel: ch)
      @grpc_channel = ch
    end

    def grpc_users
      grpc_init!
      @grpc_users ||= InvestTinkoff::GRPC::UsersService.new(invoker: @grpc_invoker)
    end

    def grpc_operations
      grpc_init!
      @grpc_operations ||= InvestTinkoff::GRPC::OperationsService.new(invoker: @grpc_invoker)
    end

    def grpc_market_data
      grpc_init!
      @grpc_market_data ||= InvestTinkoff::GRPC::MarketDataService.new(invoker: @grpc_invoker)
    end

    def grpc_market_data_stream
      grpc_init!
      @grpc_market_data_stream ||= InvestTinkoff::GRPC::MarketDataStream.new(channel: @grpc_channel)
    end

    def grpc_orders
      grpc_init!
      @grpc_orders ||= InvestTinkoff::GRPC::OrdersService.new(invoker: @grpc_invoker)
    end

    def grpc_instruments
      grpc_init!
      @grpc_instruments ||= InvestTinkoff::GRPC::InstrumentsService.new(invoker: @grpc_invoker)
    end

    private

    def get_api_request path, query = nil
      response = self.class.get(
        path,
        query: query || base_query,
        logger: @logger,
        headers: headers
      )
      parse_response response
    end

    def post_api_request path, body: {}, query: {}
      response = self.class.post(
        path,
        query: base_query.merge(query),
        body: body.to_json,
        logger: @logger,
        headers: headers
      )
      parse_response response
    end

    def headers
      {
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/json'
      }
    end

    def base_query
      return {} if @broker_account_id.nil?

      { brokerAccountId: @broker_account_id }
    end

    def parse_response response
      response.parsed_response
    end
  end
end
