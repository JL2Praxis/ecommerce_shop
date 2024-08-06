# frozen_string_literal: true

# app/graphql/mutations/update_product.rb
module Mutations
  class UpdateProduct < BaseMutation
    include Auth

    argument :id, ID, required: true
    argument :name, String, required: false
    argument :slug, String, required: false
    argument :status, Types::ProductStatusType, required: false
    argument :price, Types::PriceInputType, required: false
    argument :product_type, Types::ProductTypeType, required: false
    argument :categories, [String], required: false
    argument :description, String, required: false

    field :product, Types::ProductType, null: true
    field :error, Types::ErrorType, null: true

    PRODUCT_FIELDS = %i[name slug status product_type description].freeze

    def resolve(args)
      product = Product.find_by(id: args[:id], shop_id: current_shop_id)

      return error!(404, "Product with ID #{args[:id]} not found.", 'NOT_FOUND') if product.blank?

      update_product(product, args)

      { product: }
    end

    private

    def update_product(product, args)
      update_product_fields(product, args)
      update_product_price(product, args[:price])
      update_product_categories(product, args[:categories]) if args[:categories].present?
      product.updater_id = context[:current_user].id

      error!(422, product.errors.full_messages.join(', '), 'INVALID') unless product.save
    end

    def update_product_fields(product, args)
      args.slice(*PRODUCT_FIELDS).each do |key, value|
        product[key] = value if product.respond_to?(:"#{key}=")
      end
    end

    def update_product_price(product, price)
      product.price = BigDecimal(price[:amount], 2) if price.present?
    end

    def update_product_categories(product, args_categories)
      categories = Category.where(name: args_categories)
      new_categories = (args_categories - categories.map(&:name)).uniq.map { |name| Category.create(name:) }

      product.categories = categories + new_categories
    end
  end
end
