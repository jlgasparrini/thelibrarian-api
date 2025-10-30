class ApplicationController < ActionController::API
  include ActionController::Flash

  # Include Pundit for authorization
  include Pundit::Authorization
  include Pagy::Backend

  # Handle unauthorized access
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :role ])
  end

  def not_found
    render json: { error: "Record not found" }, status: :not_found
  end

  def user_not_authorized
    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end

  # Pagy metadata for JSON responses
  def pagy_metadata(pagy)
    {
      current_page: pagy.page,
      total_pages: pagy.pages,
      total_count: pagy.count,
      per_page: pagy.limit
    }
  end
end
