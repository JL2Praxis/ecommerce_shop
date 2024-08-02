# frozen_string_literal: true

module Types
  class PriceType < Types::BaseObject
    field :amount, String, null: false
    field :currency, String, null: false

    def amount
      return object if object.is_a?(String) || object.is_a?(BigDecimal)

      '0.00'
    end

    def currency
      'USD'
    end
  end
end
