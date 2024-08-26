# frozen_string_literal: true

module Mutations
  class PublishProduct < BaseMutation
    include Auth

    argument :id, ID, required: true

    field :product, Types::ProductType, null: true
    field :error, Types::ErrorType, null: true

    def resolve(id:)
      product = Product.find_by(id:, shop_id: current_shop_id)

      return error!(404, "Product with ID #{id} not found.", 'NOT_FOUND') if product.blank?
      return error!(422, 'Product is already published.', 'CONFLICT') if product.published?

      product.status = :published

      return error!(422, product.errors.full_messages.join(', '), 'INVALID') unless product.save

      { product: }
    end
  end
end
