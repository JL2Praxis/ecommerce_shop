# frozen_string_literal: true

# app/graphql/types/error_type.rb
module Types
  class ErrorType < Types::BaseObject
    field :code, Int, null: false
    field :message, String, null: false
    field :type, Types::ErrorTypeType, null: false
  end
end
