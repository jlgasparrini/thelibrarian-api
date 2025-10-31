# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Use environment variable for production, allow localhost for development
    origins_list = if Rails.env.production?
      # Allow both production origins and localhost for testing
      production_origins = ENV.fetch("CORS_ORIGINS", "").split(",").map(&:strip)
      localhost_origins = [ "http://localhost:3001", "http://localhost:5173", "http://localhost:3000" ]
      vercel_frontend = [ "https://thelibrarian-client.vercel.app" ]
      production_origins + localhost_origins + vercel_frontend
    else
      [ "http://localhost:3001", "http://localhost:5173", "http://localhost:3000" ]
    end

    origins origins_list

    resource "*",
      headers: :any,
      expose: [ "Authorization" ],
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
