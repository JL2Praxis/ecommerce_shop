# frozen_string_literal: true

# spec/graphql/mutations/update_product_spec.rb
require 'rails_helper'

RSpec.describe 'UpdateProduct Mutation', type: :request do
  let(:mutation) { Rails.root.join('spec/graphql_files/mutations/update_product_mutation.graphql').read }

  let(:variables) do
    {
      id: product.id,
      name: 'Updated Product',
      slug: 'updated-product',
      status: 'published',
      price: { amount: '50.0', currency: 'USD' },
      productType: 'digital',
      categories: %w[Category3 Category4],
      description: 'Updated description'
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
  let(:another_shop) { create(:shop) }
  let(:super_admin_user) do
    user = create(:user, role_id: super_admin_role.id)
    create(:shop_user, user:, shop: super_admin_shop)

    user
  end
  let(:current_user) { super_admin_user }

  let(:product) do
    create(:product, name: 'Sample Product', slug: 'sample-product', status: 'published', price: 30.0,
                     product_type: 'physical', description: 'Sample description', creator: current_user, updater: current_user, shop: super_admin_shop)
  end

  let(:another_product) do
    create(:product, name: 'Another Product', slug: 'another-product', status: 'published', price: 20.0,
                     product_type: 'physical', description: 'Another description', creator: current_user, updater: current_user, shop: another_shop)
  end

  before do
    sign_in current_user
  end

  it 'updates a product and returns its details' do
    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)

    product_data = json[:data][:updateProduct][:product]
    expect(product_data[:name]).to eq('Updated Product')
    expect(product_data[:slug]).to eq('updated-product')
    expect(product_data[:status]).to eq('published')
    expect(product_data[:price]).to eq({ amount: '50.0', currency: 'USD' })
    expect(product_data[:productType]).to eq('digital')
    expect(product_data[:categories]).to match_array(%w[Category3 Category4])
    expect(product_data[:description]).to eq('Updated description')
    expect(product_data[:updater][:id]).to eq(current_user.id.to_s)

    product.reload
    expect(product.name).to eq('Updated Product')
    expect(product.slug).to eq('updated-product')
    expect(product.status).to eq('published')
    expect(product.price).to eq(50.0)
    expect(product.product_type).to eq('digital')
    expect(product.categories.map(&:name)).to match_array(%w[Category3 Category4])
    expect(product.description).to eq('Updated description')
    expect(product.updater_id).to eq(current_user.id)
    expect(product.shop_id).to eq(super_admin_shop.id)

    expect(response).to have_http_status(:success)
  end

  it 'does not update a product not belonging to the current user\'s shop' do
    variables[:id] = another_product.id
    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)

    expect(json[:data][:updateProduct][:error][:message]).to match('Product with ID')
    expect(json[:data][:updateProduct][:error][:message]).to match(another_product.id.to_s)
    expect(json[:data][:updateProduct][:error][:message]).to match('not found.')
    expect(json[:data][:updateProduct][:error][:code]).to eq(404)
    expect(json[:data][:updateProduct][:error][:type]).to eq('NOT_FOUND')
    expect(json[:data][:updateProduct][:product]).to be_nil
  end

  it 'returns an error if the product does not exist' do
    variables[:id] = 0
    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)

    expect(json[:data][:updateProduct][:error][:message]).to eq('Product with ID 0 not found.')
    expect(json[:data][:updateProduct][:error][:code]).to eq(404)
    expect(json[:data][:updateProduct][:error][:type]).to eq('NOT_FOUND')
    expect(json[:data][:updateProduct][:product]).to be_nil
  end
end
