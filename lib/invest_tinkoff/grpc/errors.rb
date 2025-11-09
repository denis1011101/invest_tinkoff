module InvestTinkoff
  module GRPC
    class Error < StandardError; end
    class NotFound < Error; end
    class PermissionDenied < Error; end
    class Unavailable < Error; end
    class Internal < Error; end

    module ErrorMapper
      def self.map(e)
        case e.code
        when ::GRPC::Core::StatusCodes::NOT_FOUND then NotFound.new(e.details)
        when ::GRPC::Core::StatusCodes::PERMISSION_DENIED then PermissionDenied.new(e.details)
        when ::GRPC::Core::StatusCodes::UNAVAILABLE then Unavailable.new(e.details)
        when ::GRPC::Core::StatusCodes::INTERNAL then Internal.new(e.details)
        else Error.new("#{e.code}: #{e.details}")
        end
      end
    end
  end
end
