require "rake"

namespace :proto do
  DESC = "Generate gRPC Ruby code from proto"
  desc DESC
  task :generate do
    proto_dir = "proto"
    out_dir = "lib"
    # ищем рекурсивно все .proto
    files = FileList["#{proto_dir}/**/*.proto"]
    abort "No proto files found under #{proto_dir}. Put .proto files into #{proto_dir}/tinkoff/.. or run: git clone <proto-repo> #{proto_dir}" if files.empty?

    protoc = ENV["PROTOC"] || "grpc_tools_ruby_protoc"
    cmd = [protoc, "-I", proto_dir, "--ruby_out=#{out_dir}", "--grpc_out=#{out_dir}"] + files.to_a
    sh cmd.map(&:to_s).join(" ")
  end
end
