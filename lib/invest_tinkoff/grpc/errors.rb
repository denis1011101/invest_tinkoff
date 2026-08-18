module InvestTinkoff
  module GRPC
    class Error < StandardError; end
    class NotFound < Error; end
    class PermissionDenied < Error; end
    class Unavailable < Error; end
    class Internal < Error; end
    # Вызов не уложился в дедлайн из CallOptions. Отдельный класс, а не
    # потомок Unavailable: брокер мог быть жив, не успел ответить только мы.
    class DeadlineExceeded < Error; end

    module ErrorMapper
      def self.map(e)
        case e.code
        when ::GRPC::Core::StatusCodes::NOT_FOUND then NotFound.new(e.details)
        when ::GRPC::Core::StatusCodes::PERMISSION_DENIED then PermissionDenied.new(e.details)
        when ::GRPC::Core::StatusCodes::UNAVAILABLE then Unavailable.new(e.details)
        when ::GRPC::Core::StatusCodes::INTERNAL then Internal.new(e.details)
        when ::GRPC::Core::StatusCodes::DEADLINE_EXCEEDED then DeadlineExceeded.new(e.details)
        else Error.new("#{e.code}: #{e.details}")
        end
      end
    end
  end
end
