# frozen_string_literal: true

# spec/graphql/mutations/create_product_spec.rb

require 'rails_helper'

RSpec.describe 'CreateProduct Mutation', type: :request do
  let(:mutation) { Rails.root.join('spec/graphql_files/mutations/create_product_mutation.graphql').read }

  let(:variables) do
    {
      name: 'Sample Product',
      slug: 'sample-product',
      status: 'published',
      price: { amount: '30.0', currency: 'USD' },
      productType: 'physical',
      categories: %w[Category1 Category2],
      description: 'Sample description'
    }
  end

  let!(:super_admin_role) do
    return Role.find_by(level: 99) if Role.exists?(level: 99)

    create(:role, name: 'super_admin', level: 99)
  end

  let!(:admin_role) do
    return Role.find_by(level: 10) if Role.exists?(level: 10)

    create(:role, name: 'admin', level: 10)
  end

  let(:super_admin_shop) { create(:shop) }
  let(:super_admin_user) do
    user = create(:user, role_id: super_admin_role.id)
    create(:shop_user, user:, shop: super_admin_shop)

    user
  end
  let(:current_user) { super_admin_user }

  before do
    sign_in current_user
  end

  it 'creates a product and returns its details' do
    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)

    product_data = json[:data][:createProduct][:product]
    expect(product_data[:name]).to eq('Sample Product')
    expect(product_data[:slug]).to eq('sample-product')
    expect(product_data[:status]).to eq('published')
    expect(product_data[:price]).to eq({ amount: '30.0', currency: 'USD' })
    expect(product_data[:productType]).to eq('physical')
    expect(product_data[:categories]).to match_array(%w[Category1 Category2])
    expect(product_data[:description]).to eq('Sample description')
    expect(product_data[:creator][:id]).to eq(current_user.id.to_s)
    expect(product_data[:updater][:id]).to eq(current_user.id.to_s)

    product = Product.find(product_data[:id])
    expect(product.creator_id).to eq(current_user.id)
    expect(product.updater_id).to eq(current_user.id)
    expect(product.shop_id).to eq(super_admin_shop.id)

    expect(response).to have_http_status(:success)
  end
end
