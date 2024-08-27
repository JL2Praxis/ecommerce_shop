# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Queries', type: :request do
  let(:query) do
    Rails.root.join('spec/graphql_files/queries/shops_query.graphql').read
  end

  let(:variables) do
    {
      page: 1,
      perPage: 20
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

  let!(:user_role) do
    return Role.find_by(level: 1) if Role.exists?(level: 1)

    create(:role, name: 'user', level: 1)
  end

  let(:super_admin_user) { create(:user, role_id: super_admin_role.id) }
  let(:shop_admin_user) { create(:user, role_id: admin_role.id) }
  let(:regular_user) { create(:user, role_id: user_role.id) }
  let(:current_user) { super_admin_user }

  before do
    sign_in current_user
  end

  context 'when only one shop exists' do
    let!(:shop) { create(:shop) }
    let!(:shop_admin) do
      user = create(:user, role: admin_role)
      create(:shop_user, shop:, user:)

      user
    end

    it 'returns shops with admin details' do
      post '/graphql', params: { query:, variables: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      rs = json[:data][:shops]
      expect(rs[:total]).to eq(1)
      expect(rs[:error]).to be_nil

      rs_shops = rs[:shops]
      expect(rs_shops).to be_an(Array)
      expect(rs_shops.first[:name]).to eq(shop.name)

      admin_user = rs_shops.first[:admins].first
      expect(admin_user[:firstName]).to eq(shop_admin.first_name)
      expect(admin_user[:lastName]).to eq(shop_admin.last_name)
      expect(response).to have_http_status(:success)
    end
  end

  context 'when user is a shop admin' do
    let(:current_user) { shop_admin_user }
    let!(:shop) { create(:shop) }

    it 'returns shops associated with the current shop admin' do
      create(:shop_user, shop:, user: current_user)

      post '/graphql', params: { query:, variables: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      rs = json[:data][:shops]
      expect(rs[:total]).to eq(1)
      expect(rs[:error]).to be_nil

      rs_shops = rs[:shops]
      expect(rs_shops.size).to eq(1)
      expect(rs_shops.first[:name]).to eq(shop.name)
      expect(response).to have_http_status(:success)
    end
  end

  context 'when user does not have admin privileges' do
    let(:current_user) { regular_user }

    it 'returns a permission denied error' do
      post '/graphql', params: { query:, variables: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:shops][:error][:message]).to eq('You do not have permission to view the list. Only shop admins or super admins can access this resource.')
      expect(response).to have_http_status(:success)
    end
  end

  it 'paginates results' do
    create_list(:shop, 25)

    post '/graphql', params: { query:, variables: { page: 2, perPage: 20 } }, as: :json
    json = JSON.parse(response.body, symbolize_names: true)
    rs = json[:data][:shops]
    expect(rs[:total]).to eq(25)
    expect(rs[:error]).to be_nil

    rs_shops = rs[:shops]
    expect(rs_shops.size).to eq(5)
  end

  it 'defaults to the first page if no page is provided' do
    create_list(:shop, 25)

    post '/graphql', params: { query: }, as: :json
    json = JSON.parse(response.body, symbolize_names: true)
    rs = json[:data][:shops]
    expect(rs[:total]).to eq(25)
    expect(rs[:error]).to be_nil

    rs_shops = rs[:shops]
    expect(rs_shops.size).to eq(20)
  end
end
