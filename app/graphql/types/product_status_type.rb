# frozen_string_literal: true

# app/graphql/types/product_status_type.rb

module Types
  class ProductStatusType < Types::BaseEnum
    value :unknown
    value :published
    value :archived
  end
end
