# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :current_user, resolver: Queries::CurrentUser
    field :users, resolver: Queries::Users
    field :shops, resolver: Queries::Shops
    field :products, resolver: Queries::Products
    field :product_detail, resolver: Queries::ProductDetail
  end
end
