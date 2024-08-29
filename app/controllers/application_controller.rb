# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
  end

  def authenticate_user!
    return if excluded_path?
    return redirect_to after_sign_in_path_for(true), allow_other_host: true if user_signed_in?

    redirect_to new_user_session_path
  end

  def after_sign_in_path_for(_resource)
    ENV['FRONTEND_URL'] || 'http://127.0.0.1:5173/'
  end

  private

  def excluded_path?
    [
      new_user_session_path,
      new_user_registration_path,
      edit_user_password_path,
      user_password_path,
      graphql_path,
      upload_path,
      "/download/#{params[:id]}"
    ].include?(request.path)
  end
end
