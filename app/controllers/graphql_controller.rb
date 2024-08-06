# frozen_string_literal: true

class GraphqlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:execute]
  skip_before_action :authenticate_user!, only: [:execute]
  before_action :authenticate_user_for_graphql!

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user:
    }

    result = EcommerceShopSchema.execute(query, variables:, context:, operation_name:)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development(e)
  end

  private

  def prepare_variables(variables_param)
    case variables_param
    when String then parse_string_variables(variables_param)
    when Hash then variables_param
    when ActionController::Parameters then variables_param.to_unsafe_hash
    when nil then {}
    else raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  # rubocop:disable Naming/MethodParameterName
  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")
    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: :internal_server_error
  end
  # rubocop:enable Naming/MethodParameterName

  def authenticate_user_for_graphql!
    unauthorized unless current_user
  end

  def unauthorized
    render json: { error: {
      code: 401,
      message: 'You need to sign in or sign up before continuing.',
      type: 'UNAUTHORIZED'
    } }, status: :unauthorized
  end
end
