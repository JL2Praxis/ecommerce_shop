# frozen_string_literal: true

# spec/graphql/mutations/publish_product_spec.rb
require 'rails_helper'

RSpec.describe 'PublishProduct Mutation', type: :request do
  let(:mutation) { Rails.root.join('spec/graphql_files/mutations/publish_product_mutation.graphql').read }

  let(:variables) do
    {
      id: product.id
    }
  end

  let!(:shop_admin_role) do
    return Role.find_by(level: 10) if Role.exists?(level: 10)

    create(:role, name: 'admin', level: 10)
  end

  let(:current_user) { create(:user, role: shop_admin_role) }
  let(:shop) { create(:shop) }
  let!(:shop_user_relation) { create(:shop_user, user: current_user, shop:) }

  let!(:product) do
    create(:product, status: 'unpublished', shop:, creator: current_user, updater: current_user)
  end

  before do
    sign_in current_user
  end

  it 'publishes an unpublished product' do
    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)
    product_data = json[:data][:publishProduct][:product]

    expect(product_data[:id]).to eq(product.id.to_s)
    expect(product_data[:status]).to eq('published')

    product.reload
    expect(product.status).to eq('published')

    expect(response).to have_http_status(:success)
  end

  it 'returns an error if the product is already published' do
    product.update!(status: 'published')

    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)
    error_data = json[:data][:publishProduct][:error]

    expect(error_data[:message]).to eq('Product is already published.')
    expect(error_data[:code]).to eq(422)
    expect(error_data[:type]).to eq('CONFLICT')
  end

  it 'returns an error if the product does not exist' do
    variables[:id] = 0

    post '/graphql', params: { query: mutation, variables: }, as: :json

    json = JSON.parse(response.body, symbolize_names: true)
    error_data = json[:data][:publishProduct][:error]

    expect(error_data[:message]).to eq('Product with ID 0 not found.')
    expect(error_data[:code]).to eq(404)
    expect(error_data[:type]).to eq('NOT_FOUND')
  end
end
