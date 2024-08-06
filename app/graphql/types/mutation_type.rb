# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_shop, mutation: Mutations::CreateShop
    field :create_product, mutation: Mutations::CreateProduct
    field :update_product, mutation: Mutations::UpdateProduct
  end
end
