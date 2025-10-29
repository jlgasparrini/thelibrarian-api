module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              message: "Signed up successfully.",
              user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
            }, status: :created
          else
            render json: {
              message: 'User could not be created.',
              errors: resource.errors.full_messages
            }, status: :unprocessable_content
          end
        end
      end
    end
  end
end
