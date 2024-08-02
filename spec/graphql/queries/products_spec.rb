# frozen_string_literal: true

# spec/graphql/queries/products_spec.rb
require 'rails_helper'

RSpec.describe 'Products Query', type: :request do
  let(:query) { Rails.root.join('spec/graphql_files/queries/products_query.graphql').read }

  let(:variables) do
    {
      page: 1,
      perPage: 20
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
  let!(:shop1_products) do
    Array.new(25) do
      product = create(:product, creator: shop1_product_creator, updater: shop1_product_updater, shop: shop1)
      product.categories << [shop1_product_category1, shop1_product_category2]

      product
    end
  end

  context 'user is shop1 admin' do
    let(:current_user) { shop1_admin_user }

    it 'returns products with pagination' do
      post '/graphql', params: { query:, variables: }, headers:, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      results_products = json[:data][:products]

      expect(results_products.size).to eq(20)
      expect(results_products.first[:name]).to eq(shop1_products.first.name)
      expect(results_products.first[:slug]).to eq(shop1_products.first.slug)
      expect(results_products.first[:status]).to eq(shop1_products.first.status)
      expect(results_products.first[:price]).to eq({ amount: shop1_products.first.price.to_s, currency: 'USD' })
      expect(results_products.first[:productType]).to eq(shop1_products.first.product_type)
      expect(results_products.first[:description]).to eq(shop1_products.first.description)
      expect(results_products.first[:categories]).to eq([shop1_product_category1.name, shop1_product_category2.name])
      expect(results_products.first[:creator][:email]).to eq(shop1_product_creator.email)
      expect(results_products.first[:updater][:email]).to eq(shop1_product_updater.email)
      expect(response).to have_http_status(:success)
    end

    it 'paginates results' do
      post '/graphql', params: { query:, variables: { page: 2, perPage: 20 } }, headers:, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      products = json[:data][:products]

      expect(products.size).to eq(5)
    end

    it 'defaults to the first page if no page is provided' do
      post '/graphql', params: { query: }, headers:, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      products = json[:data][:products]

      expect(products.size).to eq(20)
    end
  end

  context 'user is shop2 admin' do
    let(:current_user) { shop2_admin_user }

    it 'returns products with pagination' do
      post '/graphql', params: { query:, variables: }, headers:, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      results_products = json[:data][:products]

      expect(results_products.size).to eq(0)
      expect(response).to have_http_status(:success)
    end
  end
end
