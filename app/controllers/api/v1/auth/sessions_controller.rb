module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json
        skip_before_action :verify_signed_out_user, only: :destroy

        private

        def respond_with(resource, _opts = {})
          render json: {
            message: "Logged in successfully.",
            user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
          }, status: :ok
        end

        def respond_to_on_destroy
          if request.headers["Authorization"].present?
            jwt_payload = JWT.decode(request.headers["Authorization"].split(" ").last, ENV["JWT_SECRET_KEY"] || Rails.application.credentials.secret_key_base).first
            current_user = User.find(jwt_payload["sub"])
          end

          if current_user
            render json: {
              message: "Logged out successfully."
            }, status: :ok
          else
            render json: {
              message: "No active session."
            }, status: :unauthorized
          end
        end
      end
    end
  end
end
