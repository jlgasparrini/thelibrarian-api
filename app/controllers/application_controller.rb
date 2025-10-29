class ApplicationController < ActionController::API
  # Include helpers for ActiveAdmin compatibility
  # ActiveAdmin requires helper_method which is not available in ActionController::API
  include ActionController::Helpers

  # Include Flash for Devise compatibility
  include ActionController::Flash
end
