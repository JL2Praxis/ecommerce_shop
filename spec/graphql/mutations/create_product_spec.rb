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

  let!(:shop_admin_role) do
    return Role.find_by(level: 10) if Role.exists?(level: 10)

    create(:role, name: 'admin', level: 10)
  end

  let(:super_admin_user) do
    user = create(:user, role_id: super_admin_role.id)
    create(:shop_user, user:, shop: shop_admin_shop)

    user
  end

  let(:shop_admin_shop) { create(:shop) }
  let(:shop_admin_user) do
    user = create(:user, role_id: shop_admin_role.id)
    create(:shop_user, user:, shop: shop_admin_shop)

    user
  end

  let(:buyer) { create(:user, role_id: create(:role, name: 'buyer', level: 1).id) }
  let(:current_user) { shop_admin_user }
  before { sign_in current_user }

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
    expect(product.shop_id).to eq(shop_admin_shop.id)

    expect(response).to have_http_status(:success)
  end

  it 'returns an error if the user is not an admin' do
    sign_out current_user
    sign_in buyer

    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)
    res = json[:data][:createProduct]
    expect(res[:product]).to be_blank

    res_error = res[:error]
    expect(res_error).not_to be_blank
    expect(res_error[:code]).to eq(403)
    expect(res_error[:message]).to eq('You do not have permission to create a product.')
    expect(res_error[:type]).to eq('UNAUTHORIZED')

    expect(response).to have_http_status(:success)
  end

  it 'returns an error if product save fails' do
    allow_any_instance_of(Product).to receive(:save).and_return(false)
    allow_any_instance_of(Product).to receive_message_chain(:errors, :full_messages).and_return(['Name can\'t be blank'])

    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)
    res = json[:data][:createProduct]

    expect(res[:product]).to be_blank

    res_error = res[:error]
    expect(res_error).not_to be_blank
    expect(res_error[:code]).to eq(422)
    expect(res_error[:message]).to eq('Name can\'t be blank')
    expect(res_error[:type]).to eq('INVALID')
  end
end
