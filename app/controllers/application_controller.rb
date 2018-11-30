class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
  end

  private

  def user_not_authorized
    flash[:alert] = "Nie możesz edytować tej wiadomości!!!"
    redirect_to(request.referrer || root_path)
  end
end
