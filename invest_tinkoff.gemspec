lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'invest_tinkoff/version'

Gem::Specification.new do |s|
  s.name        = 'invest_tinkoff_grpc'
  s.version     = InvestTinkoff::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2025-11-08'
  s.summary     = 'invest_tinkoff_grpc'
  s.description = 'Tinkoff Invest Ruby rest and gRPC API Gem'
  s.authors     = ['Denis Levenko']
  s.email       = 'denisdenis9331@gmail.com'
  s.files += Dir.glob('README*') + Dir.glob('LICENSE*') + Dir.glob('Rakefile*') + Dir.glob('Gemfile*')
  s.require_paths = ['lib']
  s.homepage    = 'https://github.com/denis1011101/invest_tinkoff'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.4.6'

  s.add_dependency 'google-protobuf', '~> 4.31', '>= 4.31.1'
  s.add_dependency 'grpc', '~> 1.74', '>= 1.74.1'
  s.add_dependency 'httparty', '~> 0.23.1'

  s.metadata = {
    'source_code_uri' => s.homepage,
    'changelog_uri'   => "#{s.homepage}/releases"
  }
end
