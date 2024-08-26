# frozen_string_literal: true

module Queries
  class Products < GraphQL::Schema::Resolver
    include Auth

    description 'Get all products with pagination'

    argument :page, Integer, required: false
    argument :per_page, Integer, required: false

    type [Types::ProductType], null: false

    def resolve(page: 1, per_page: 20)
      page = page.to_i
      page = 1 if page < 1
      per_page = per_page.to_i
      per_page = 20 if per_page < 1

      Product.includes(:categories, :creator, :updater)
             .where(shop_id: current_shop_id)
             .where(status: Product::ALLOWED_PRODUCT_STATUSES)
             .page(page)
             .per(per_page)
    end
  end
end
