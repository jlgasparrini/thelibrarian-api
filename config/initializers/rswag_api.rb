Rswag::Api.configure do |c|
  # Specify a root folder where Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  # NOTE: If you're using rswag-specs to generate Swagger, you'll need to ensure
  # that it's configured to generate files in the same folder
  c.openapi_root = Rails.root.to_s + "/swagger"

  # Make Swagger servers dynamic so localhost appears while running locally
  c.swagger_filter = lambda { |swagger, env|
    scheme = env["rack.url_scheme"] || "http"
    host = env["HTTP_HOST"] || "localhost:3000"
    current = {
      "url" => "#{scheme}://#{host}",
      "description" => (Rails.env.production? ? "Production server" : "Development server")
    }

    # Keep production as a secondary option for convenience
    production = {
      "url" => "https://thelibrarian-api.onrender.com",
      "description" => "Production server"
    }

    swagger["servers"] = [ current, production ]
  }
end
