# frozen_string_literal: true

module Types
  class UsersPayloadType < Types::BaseObject
    field :users, [Types::UserType], null: false
    field :total, Integer, null: false
    field :error, Types::ErrorType, null: true
  end
end

module Queries
  class Users < GraphQL::Schema::Resolver
    include Auth

    argument :page, Integer, required: false
    argument :per_page, Integer, required: false

    type Types::UsersPayloadType, null: false

    def resolve(page: 1, per_page: 20)
      page = page.to_i
      page = 1 if page < 1
      per_page = per_page.to_i
      per_page = 20 if per_page < 1

      users = shop_users.page(page).per(per_page)

      { users:, total: shop_users.count }
    end

    private

    def shop_users
      return User.all if super_admin?

      User.joins(:shop_users).where(shop_users: { shop_id: current_shop_id })
    end
  end
end
