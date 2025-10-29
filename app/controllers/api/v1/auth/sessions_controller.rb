module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        include JwtAuthentication
        
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
            token = request.headers["Authorization"].split(" ").last
            jwt_payload = decode_jwt_token(token)
            current_user = User.find(jwt_payload["sub"]) if jwt_payload
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
