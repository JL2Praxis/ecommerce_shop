# frozen_string_literal: true

# spec/graphql/queries/product_detail_spec.rb
require 'rails_helper'

RSpec.describe 'ProductDetail Query', type: :request do
  let(:query) { Rails.root.join('spec/graphql_files/queries/product_detail_query.graphql').read }

  let(:variables) do
    {
      id: product.id
    }
  end

  let!(:shop_admin_role) do
    return Role.find_by(level: 10) if Role.exists?(level: 10)

    create(:role, name: 'admin', level: 10)
  end

  let!(:shop1_admin_user) { create(:user, role: shop_admin_role) }
  let!(:shop1) { create(:shop) }
  let!(:shop1_admin_relation) { create(:shop_user, user: shop1_admin_user, shop: shop1) }
  let!(:shop2_admin_user) { create(:user, role: shop_admin_role) }
  let!(:shop2) { create(:shop) }
  let!(:shop2_admin_relation) { create(:shop_user, user: shop2_admin_user, shop: shop2) }

  before do
    sign_in current_user
  end

  let(:shop1_product_creator) { create(:user) }
  let(:shop1_product_updater) { create(:user) }
  let(:shop1_product_category1) { create(:category, name: 'Category1') }
  let(:shop1_product_category2) { create(:category, name: 'Category2') }
  let!(:product) do
    product = create(:product, creator: shop1_product_creator, updater: shop1_product_updater, shop: shop1)
    product.categories << [shop1_product_category1, shop1_product_category2]
    product
  end

  let!(:deleted_product) do
    create(:product, status: 'deleted', shop: shop1)
  end

  context 'user is shop1 admin' do
    let(:current_user) { shop1_admin_user }

    it 'returns product details for a valid product ID' do
      post '/graphql', params: { query:, variables: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      product_data = json[:data][:productDetail][:product]

      expect(product_data[:id]).to eq(product.id.to_s)
      expect(product_data[:name]).to eq(product.name)
      expect(product_data[:slug]).to eq(product.slug)
      expect(product_data[:status]).to eq(product.status)
      expect(product_data[:price]).to eq({ amount: product.price.to_s, currency: 'USD' })
      expect(product_data[:productType]).to eq(product.product_type)
      expect(product_data[:description]).to eq(product.description)
      expect(product_data[:categories]).to eq([shop1_product_category1.name, shop1_product_category2.name])
      expect(product_data[:creator][:email]).to eq(shop1_product_creator.email)
      expect(product_data[:updater][:email]).to eq(shop1_product_updater.email)
      expect(product_data[:createdAt]).to eq(product.created_at.to_i)
      expect(product_data[:updatedAt]).to eq(product.updated_at.to_i)
      expect(response).to have_http_status(:success)
    end

    it 'returns an error for a deleted product' do
      variables[:id] = deleted_product.id
      post '/graphql', params: { query:, variables: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      err = json[:data][:productDetail][:error]

      expect(err[:message]).to eq("Product with ID #{deleted_product.id} not found.")
      expect(response).to have_http_status(:success)
    end

    it 'returns an error if the product does not belong to the current user\'s shop' do
      variables[:id] = create(:product, shop: shop2).id
      post '/graphql', params: { query:, variables: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      err = json[:data][:productDetail][:error]

      expect(err[:message]).to eq("Product with ID #{variables[:id]} not found.")
      expect(response).to have_http_status(:success)
    end
  end
end
