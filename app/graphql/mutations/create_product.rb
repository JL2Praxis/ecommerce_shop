# frozen_string_literal: true

# app/graphql/mutations/create_product.rb
module Mutations
  class CreateProduct < BaseMutation
    argument :name, String, required: true
    argument :slug, String, required: true
    argument :status, Types::ProductStatusType, required: true
    argument :price, Types::PriceInputType, required: true
    argument :product_type, Types::ProductTypeType, required: true
    argument :categories, [String], required: false
    argument :description, String, required: false

    field :product, Types::ProductType, null: false

    PRODUCT_FIELDS = %i[name slug status product_type description creator_id updater_id].freeze
    def resolve(args)
      # TODO: (Jayne) return error if user is not admin

      categories = product_categories(args[:categories])

      product = Product.new(args.slice(*PRODUCT_FIELDS))
      price_amount = BigDecimal(args.dig(:price, :amount), 2)
      assign_product_attributes(product, categories, price_amount)
      product.save!

      { product: }
    end

    def product_categories(args_categories)
      categories = Category.where(name: args_categories).map(&:name)
      new_categories = (args_categories - categories.map(&:name)).uniq.map { |name| Category.create(name:) }

      categories + new_categories
    end

    def assign_product_attributes(product, categories, price_amount)
      product.categories << categories
      product.shop_id = shop_id
      product.creator_id = context[:current_user].id
      product.updater_id = context[:current_user].id
      product.price = price_amount
    end

    def shop_id
      context[:current_user].shops.first&.id
    end
  end
end
