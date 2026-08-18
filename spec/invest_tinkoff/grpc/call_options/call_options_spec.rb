# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InvestTinkoff::GRPC::CallOptions do
  let(:channel) { double('channel', metadata: { 'authorization' => 'Bearer t' }) }

  describe '.timeout_seconds' do
    it 'defaults when the variable is unset or blank' do
      expect(described_class.timeout_seconds({})).to eq(described_class::DEFAULT_TIMEOUT_SECONDS)
      expect(described_class.timeout_seconds({ 'INVEST_TINKOFF_GRPC_TIMEOUT' => '  ' }))
        .to eq(described_class::DEFAULT_TIMEOUT_SECONDS)
    end

    it 'reads an explicit value' do
      expect(described_class.timeout_seconds({ 'INVEST_TINKOFF_GRPC_TIMEOUT' => '7.5' })).to eq(7.5)
    end

    it 'disables the deadline only on an explicit non-positive value' do
      expect(described_class.timeout_seconds({ 'INVEST_TINKOFF_GRPC_TIMEOUT' => '0' })).to be_nil
      expect(described_class.timeout_seconds({ 'INVEST_TINKOFF_GRPC_TIMEOUT' => '-1' })).to be_nil
    end

    it 'falls back to the default on garbage instead of silently dropping the deadline' do
      expect(described_class.timeout_seconds({ 'INVEST_TINKOFF_GRPC_TIMEOUT' => 'soon' }))
        .to eq(described_class::DEFAULT_TIMEOUT_SECONDS)
    end

    # Float('1e400') это не nil, а Infinity: без проверки finite? такой дедлайн
    # ронял бы FloatDomainError на каждом вызове, то есть весь клиент.
    it 'falls back to the default on an overflowing value instead of building an infinite deadline' do
      %w[1e400 1e100000 -1e400].each do |raw|
        expect(described_class.timeout_seconds({ 'INVEST_TINKOFF_GRPC_TIMEOUT' => raw }))
          .to eq(described_class::DEFAULT_TIMEOUT_SECONDS)
      end

      expect { described_class.build(channel, timeout: described_class.timeout_seconds({ 'INVEST_TINKOFF_GRPC_TIMEOUT' => '1e400' })) }
        .not_to raise_error
    end
  end

  describe '.build' do
    it 'carries the channel metadata and an absolute deadline' do
      now = Time.utc(2026, 8, 18, 17, 40, 0)
      options = described_class.build(channel, timeout: 30.0, now: now)

      expect(options[:metadata]).to eq('authorization' => 'Bearer t')
      expect(options[:deadline]).to eq(now + 30.0)
    end

    it 'omits the deadline when it is disabled' do
      options = described_class.build(channel, timeout: nil)

      expect(options).to eq(metadata: { 'authorization' => 'Bearer t' })
      expect(options).not_to have_key(:deadline)
    end
  end

  # Ради этого всё и делалось: ни один RPC не должен уходить в канал без дедлайна.
  describe 'service wiring' do
    services = {
      InvestTinkoff::GRPC::UsersService => [[:accounts, [], :get_accounts]],
      InvestTinkoff::GRPC::MarketDataService => [
        [:last_prices, [{ figis: ['BBG'] }], :get_last_prices],
        [:candles, [{ figi: 'BBG', from: Time.utc(2026, 8, 1), to: Time.utc(2026, 8, 2), interval: 1 }], :get_candles]
      ],
      InvestTinkoff::GRPC::OrdersService => [
        [:get_orders, [{ account_id: 'acc' }], :get_orders]
      ],
      InvestTinkoff::GRPC::OperationsService => [
        [:portfolio, [{ account_id: 'acc' }], :get_portfolio]
      ],
      InvestTinkoff::GRPC::InstrumentsService => [
        [:find_instrument, [{ query: 'SBER' }], :find_instrument],
        [:indicatives, [], :indicatives]
      ]
    }

    services.each do |klass, calls|
      calls.each do |wrapper, args, rpc|
        it "passes a deadline through #{klass.name.split('::').last}##{wrapper}" do
          stub = double('grpc_stub')
          service = klass.allocate
          service.instance_variable_set(:@invoker, double('invoker', channel: channel))
          service.instance_variable_set(:@stub, stub)

          captured = nil
          allow(stub).to receive(rpc) do |_req, **opts|
            captured = opts
            double('resp', instrument: nil, instruments: [])
          end

          args.empty? ? service.public_send(wrapper) : service.public_send(wrapper, **args.first)

          expect(captured[:metadata]).to eq('authorization' => 'Bearer t')
          expect(captured[:deadline]).to be_a(Time)
          expect(captured[:deadline]).to be > Time.now
        end
      end
    end
  end
end
