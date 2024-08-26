# frozen_string_literal: true

module Types
  class ProductDetailPayloadType < Types::BaseObject
    field :product, Types::ProductType, null: true
    field :error, Types::ErrorType, null: true
  end
end

module Queries
  class ProductDetail < GraphQL::Schema::Resolver
    include Auth

    description 'Get a single product'

    argument :id, ID, required: true

    type Types::ProductDetailPayloadType, null: true

    def resolve(id:)
      product = Product.includes(:categories, :creator, :updater)
                       .where(shop_id: current_shop_id)
                       .where(status: Product::ALLOWED_PRODUCT_STATUSES)
                       .find_by(id: id.presence || -1)

      return { error: { message: "Product with ID #{id} not found.", code: 404, type: 'NOT_FOUND' } } if product.blank?

      { product: }
    end
  end
end
