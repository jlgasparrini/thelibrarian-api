module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!

      def me
        render json: {
          user: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
        }, status: :ok
      end
    end
  end
end
