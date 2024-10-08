# frozen_string_literal: true

# app/graphql/types/error_type_type.rb
module Types
  class ErrorTypeType < Types::BaseEnum
    value 'UNAUTHORIZED', 'Unauthorized error'
    value 'PERMISSION_DENIED', 'Permission Denied'
    value 'INVALID', 'Invalid input error'
    value 'NOT_FOUND', 'Resource not found error'
    value 'CONFLICT', 'Resource conflict error'
  end
end
