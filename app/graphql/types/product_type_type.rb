# frozen_string_literal: true

# app/graphql/types/product_type_type.rb

module Types
  class ProductTypeType < Types::BaseEnum
    value :unknown
    value :physical
    value :digital
    value :service
    value :advanced
  end
end
