#!/usr/bin/env ruby
# Создаёт shim-файлы под lib/tinkoff/public/invest/api/contract/v1/,
# которые просто require соответствующих сгенерированных файлов в lib/.

require 'fileutils'
require 'pathname'

ROOT = File.expand_path('..', __dir__)
LIB = File.join(ROOT, 'lib')
TARGET_BASE = File.join(LIB, 'tinkoff/public/invest/api/contract/v1')

# шаблон поиска сгенерированных файлов в lib/
generated = Dir[File.join(LIB, '*_pb.rb')] + Dir[File.join(LIB, '*_services_pb.rb')]
if generated.empty?
  puts "No generated *_pb.rb or *_services_pb.rb files found under #{LIB}"
  exit 1
end

FileUtils.mkdir_p(TARGET_BASE)

generated.each do |f|
  basename = File.basename(f) # e.g. users_pb.rb
  shim_path = File.join(TARGET_BASE, basename)

  # compute relative path from shim file to the generated file, without .rb
  require_path = Pathname.new(f).relative_path_from(Pathname.new(File.dirname(shim_path))).to_s.sub(/\.rb\z/, '')

  content = <<~RUBY
    # Auto-generated shim to preserve expected namespace path.
    # This file requires the generated protobuf file placed in lib/
    require_relative '#{require_path}'
  RUBY

  if File.exist?(shim_path)
    puts "Skipping existing shim: #{shim_path}"
  else
    File.write(shim_path, content)
    puts "Created shim: #{shim_path}"
  end
end

puts "Done. Shims created under #{TARGET_BASE}"
