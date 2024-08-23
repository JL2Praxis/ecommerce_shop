# frozen_string_literal: true

# spec/graphql/mutations/delete_product_spec.rb
require 'rails_helper'

RSpec.describe 'DeleteProduct Mutation', type: :request do
  let(:mutation) { Rails.root.join('spec/graphql_files/mutations/delete_product_mutation.graphql').read }

  let(:variables) do
    {
      id: product.id
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

  it 'deletes a product and marks it as deleted' do
    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:data][:deleteProduct][:error]).to be_nil

    product.reload
    expect(product.status).to eq('deleted')

    expect(response).to have_http_status(:success)
  end

  it 'does not delete a product not belonging to the current user\'s shop' do
    variables[:id] = another_product.id
    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)

    expect(json[:data][:deleteProduct][:error][:message]).to match('Product with ID')
    expect(json[:data][:deleteProduct][:error][:message]).to match(another_product.id.to_s)
    expect(json[:data][:deleteProduct][:error][:message]).to match('not found.')
    expect(json[:data][:deleteProduct][:error][:code]).to eq(404)
    expect(json[:data][:deleteProduct][:error][:type]).to eq('NOT_FOUND')
  end

  it 'returns an error if the product does not exist' do
    variables[:id] = 0
    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)

    expect(json[:data][:deleteProduct][:error][:message]).to eq('Product with ID 0 not found.')
    expect(json[:data][:deleteProduct][:error][:code]).to eq(404)
    expect(json[:data][:deleteProduct][:error][:type]).to eq('NOT_FOUND')
  end
end
