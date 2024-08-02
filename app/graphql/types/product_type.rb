# frozen_string_literal: true

# app/graphql/types/product_type.rb
module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :status, Types::ProductStatusType, null: false
    field :price, Types::PriceType, null: false
    field :product_type, Types::ProductTypeType, null: false
    field :categories, [String], null: true
    field :description, String, null: true
    field :updated_at, Integer, null: false
    field :created_at, Integer, null: false
    field :creator, UserType, null: false
    field :updater, UserType, null: false

    def categories
      object.categories.map(&:name)
    end
  end
end
