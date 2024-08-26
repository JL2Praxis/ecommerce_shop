# frozen_string_literal: true

# app/graphql/mutations/delete_product.rb
module Mutations
  class DeleteProduct < BaseMutation
    include Auth

    argument :id, ID, required: true

    field :error, Types::ErrorType, null: true

    def resolve(args)
      product = Product.find_by(id: args[:id], shop_id: current_shop_id)

      return error!(404, "Product with ID #{args[:id]} not found.", 'NOT_FOUND') if product.blank?

      product.status = :deleted

      error!(422, product.errors.full_messages.join(', '), 'INVALID') unless product.save

      {}
    end
  end
end
