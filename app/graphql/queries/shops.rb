# frozen_string_literal: true

module Types
  class ShopsPayloadType < Types::BaseObject
    field :shops, [Types::ShopType], null: true
    field :total, Integer, null: true
    field :error, Types::ErrorType, null: true
  end
end

module Queries
  class Shops < GraphQL::Schema::Resolver
    include Auth

    description 'Get all shops with pagination'

    argument :page, Integer, required: false
    argument :per_page, Integer, required: false

    type Types::ShopsPayloadType, null: false

    def resolve(page: 1, per_page: 20)
      return error!(403, PERMISSION_DENIED_ERR_MSG, 'PERMISSION_DENIED') unless shop_admin? || super_admin?

      page = page.to_i
      page = 1 if page < 1
      per_page = per_page.to_i
      per_page = 20 if per_page < 1

      shops = Shop.includes(admins: :role)
      shops = shops.where(id: current_shop_id) if shop_admin?

      final_shops = shops.page(page).per(per_page)

      { shops: final_shops, total: shops.count }
    end
  end
end
