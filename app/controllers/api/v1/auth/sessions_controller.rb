module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        include JwtAuthentication

        respond_to :json
        skip_before_action :verify_signed_out_user, only: :destroy

        # Enforce email/password authentication (ignores any existing JWT/session)
        def create
          creds = params.require(:user).permit(:email, :password)
          email = creds[:email].to_s.downcase.strip
          password = creds[:password].to_s

          user = User.find_for_authentication(email: email)

          unless user && user.valid_for_authentication? { user.valid_password?(password) }
            return render json: { error: "Invalid email or password" }, status: :unauthorized
          end

          sign_in(resource_name, user)
          respond_with(user)
        end

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
