# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :shop

  belongs_to :creator, class_name: 'User'
  belongs_to :updater, class_name: 'User'

  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  enum status: { published: 0, archived: 1, hidden: 2 }

  validates :name, :slug, :status, :price, :product_type, presence: true
end

# == Schema Information
#
# Table name: products
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  slug         :string           not null
#  status       :integer          default("published"), not null
#  price        :decimal(10, 2)   not null
#  product_type :string           not null
#  description  :text
#  shop_id      :bigint           not null
#  creator_id   :bigint           not null
#  updater_id   :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_products_on_creator_id  (creator_id)
#  index_products_on_shop_id     (shop_id)
#  index_products_on_updater_id  (updater_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (shop_id => shops.id)
#  fk_rails_...  (updater_id => users.id)
#
