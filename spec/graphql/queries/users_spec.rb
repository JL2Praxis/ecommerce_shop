# frozen_string_literal: true

# spec/graphql/queries/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users Query', type: :request do
  let(:query) { Rails.root.join('spec/graphql_files/queries/users_query.graphql').read }

  let(:variables) do
    {
      page: 1,
      perPage: 20
    }
  end

  let!(:superadmin_role) do
    return Role.find_by(level: 99) if Role.exists?(level: 99)

    create(:role, name: 'superadmin', level: 99)
  end

  let!(:admin_role) do
    return Role.find_by(level: 10) if Role.exists?(level: 10)

    create(:role, name: 'admin', level: 10)
  end

  let!(:user_role) do
    return Role.find_by(level: 1) if Role.exists?(level: 1)

    create(:role, name: 'user', level: 1)
  end

  let!(:shop1_admin_user) { create(:user, role: admin_role) }
  let!(:shop1) { create(:shop) }
  let!(:shop1_admin_relation) { create(:shop_user, user: shop1_admin_user, shop: shop1) }

  let!(:shop2_admin_user) { create(:user, role: admin_role) }
  let!(:shop2) { create(:shop) }
  let!(:shop2_admin_relation) { create(:shop_user, user: shop2_admin_user, shop: shop2) }

  before do
    sign_in current_user
  end

  let!(:shop1_users) do
    Array.new(25) do
      user = create(:user, role: user_role)
      create(:shop_user, user:, shop: shop1)

      user
    end
  end

  context 'user is shop1 admin' do
    let(:current_user) { shop1_admin_user }

    it 'returns users associated with shop1 with pagination' do
      post '/graphql', params: { query:, variables: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      rs = json[:data][:users]
      expect(rs[:total]).to eq(26)
      expect(rs[:error]).to be_nil

      rs_users = rs[:users]
      expect(rs_users.size).to eq(20)
      expect(rs_users.first[:email]).to eq(shop1_admin_user.email)
      expect(rs_users.second[:email]).to eq(shop1_users.first.email)

      expect(response).to have_http_status(:success)
    end

    it 'paginates results' do
      post '/graphql', params: { query:, variables: { page: 2, perPage: 20 } }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      rs = json[:data][:users]
      expect(rs[:total]).to eq(26)
      expect(rs[:error]).to be_nil
      expect(rs[:users].size).to eq(6)
    end

    it 'defaults to the first page if no page is provided' do
      post '/graphql', params: { query: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      rs = json[:data][:users]
      expect(rs[:total]).to eq(26)
      expect(rs[:error]).to be_nil
      expect(rs[:users].size).to eq(20)
    end
  end

  context 'user is shop2 admin' do
    let(:current_user) { shop2_admin_user }

    it 'returns only admin user if the shop has no other users' do
      post '/graphql', params: { query:, variables: }, as: :json

      json = JSON.parse(response.body, symbolize_names: true)
      results_users = json[:data][:users][:users]

      expect(results_users.size).to eq(1)
      expect(response).to have_http_status(:success)
    end
  end
end
