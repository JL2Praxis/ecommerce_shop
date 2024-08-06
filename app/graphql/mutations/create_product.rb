# frozen_string_literal: true

# app/graphql/mutations/create_product.rb
module Mutations
  class CreateProduct < BaseMutation
    include Auth

    argument :name, String, required: true
    argument :slug, String, required: true
    argument :status, Types::ProductStatusType, required: true
    argument :price, Types::PriceInputType, required: true
    argument :product_type, Types::ProductTypeType, required: true
    argument :categories, [String], required: false
    argument :description, String, required: false

    field :product, Types::ProductType, null: true
    field :error, Types::ErrorType, null: true

    PRODUCT_FIELDS = %i[name slug status product_type description creator_id updater_id].freeze

    def resolve(args)
      return error!(403, 'You do not have permission to create a product.', 'UNAUTHORIZED') unless shop_admin?

      categories = product_categories(args[:categories])

      product = Product.new(args.slice(*PRODUCT_FIELDS))
      price_amount = BigDecimal(args.dig(:price, :amount), 2)
      assign_product_attributes(product, categories, price_amount)

      return error!(422, product.errors.full_messages.join(', '), 'INVALID') unless product.save

      { product:, error: nil }
    end

    private

    def product_categories(args_categories)
      categories = Category.where(name: args_categories)
      new_categories = (args_categories - categories.map(&:name)).uniq.map { |name| Category.create(name:) }

      categories + new_categories
    end

    def assign_product_attributes(product, categories, price_amount)
      product.categories << categories
      product.shop_id = current_shop_id
      product.creator_id = context[:current_user].id
      product.updater_id = context[:current_user].id
      product.price = price_amount
    end
  end
end
