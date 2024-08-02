# frozen_string_literal: true

# app/graphql/types/price_input_type.rb
module Types
  class PriceInputType < Types::BaseInputObject
    argument :amount, Types::BigDecimalType, required: true
    argument :currency, String, required: true
  end
end
