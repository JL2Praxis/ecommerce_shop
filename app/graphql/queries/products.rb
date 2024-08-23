# frozen_string_literal: true

module Queries
  class Products < GraphQL::Schema::Resolver
    description 'Get all products with pagination'

    argument :page, Integer, required: false
    argument :per_page, Integer, required: false

    type [Types::ProductType], null: false

    ALLOWED_PRODUCT_STATUSES = (Product.statuses.keys - ['deleted']).freeze

    def resolve(page: 1, per_page: 20)
      page = page.to_i
      page = 1 if page < 1
      per_page = per_page.to_i
      per_page = 20 if per_page < 1

      Product.includes(:categories, :creator, :updater)
             .where(shop_id: context[:current_user].shops.pluck(:id))
             .where(status: ALLOWED_PRODUCT_STATUSES)
             .page(page)
             .per(per_page)
    end
  end
end
