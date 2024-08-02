# frozen_string_literal: true

# app/graphql/types/big_decimal_type.rb
module Types
  class BigDecimalType < Types::BaseScalar
    description 'A valid decimal number'

    def self.coerce_input(input_value, _context)
      BigDecimal(input_value.to_s)
    rescue ArgumentError
      raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid decimal number"
    end

    def self.coerce_result(ruby_value, _context)
      ruby_value.to_s('F')
    end
  end
end
