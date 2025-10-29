module Api
  module V1
    class DashboardsController < ApplicationController
      before_action :authenticate_user!

      def show
        authorize :dashboard, :show?
        
        dashboard_data = DashboardService.new(current_user).call
        render json: dashboard_data, status: :ok
      end
    end
  end
end
