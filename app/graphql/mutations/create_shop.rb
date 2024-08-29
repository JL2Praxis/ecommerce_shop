# frozen_string_literal: true

module Mutations
  class CreateShop < BaseMutation
    include Auth

    argument :shop_name, String, required: true
    argument :admin_email, String, required: true
    argument :admin_first_name, String, required: true
    argument :admin_last_name, String, required: true

    field :shop, Types::ShopType, null: true
    field :admin_user, Types::UserType, null: true
    field :error, Types::ErrorType, null: true

    def resolve(args)
      return error!(403, 'You do not have permission to create a shop.', 'UNAUTHORIZED') unless super_admin?

      validate_uniqueness(args[:admin_email], args[:shop_name])

      admin_user = create_admin_user(args[:admin_email], args[:admin_first_name], args[:admin_last_name])

      shop = create_shop_and_shop_admin!(args[:shop_name], admin_user)

      { shop:, admin_user:, error: nil }
    rescue GraphQL::ExecutionError, ActiveRecord::RecordInvalid => e
      Rails.logger.info "Failed to create shop: #{e.message}"

      error!(422, e.message, 'INVALID')
    end

    private

    def create_shop_and_shop_admin!(shop_name, admin_user)
      shop = Shop.new(name: shop_name)
      shop.admins << admin_user

      raise ActiveRecord::RecordInvalid, shop unless shop.save

      shop
    end

    def validate_uniqueness(email, shop_name)
      if User.exists?(email:)
        raise GraphQL::ExecutionError, 'Email is already taken'
      elsif Shop.exists?(name: shop_name)
        raise GraphQL::ExecutionError, 'Shop name is already taken'
      end
    end

    def create_admin_user(email, first_name, last_name)
      admin_role = Role.find_by(level: Role::SHOP_ADMIN_LEVEL)
      raise GraphQL::ExecutionError, 'Admin role not found' if admin_role.nil?

      pwd = Devise.friendly_token[0, 20]
      admin_user = User.create!(
        email:,
        first_name:,
        last_name:,
        role_id: admin_role.id,
        password: pwd,
        password_confirmation: pwd
      )

      admin_user.send_reset_password_instructions

      admin_user
    end
  end
end
