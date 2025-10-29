module Api
  module V1
    class HealthController < ApplicationController
      def index
        render json: { status: "ok", message: "API is running" }, status: :ok
      end
    end
  end
end
