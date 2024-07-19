class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def authenticate_user!
    return if excluded_path?

    redirect_to new_user_session_path
  end

  private

  def excluded_path?
    [
      new_user_session_path, 
      new_user_registration_path,
      graphql_path
    ].include?(request.path)
  end
end