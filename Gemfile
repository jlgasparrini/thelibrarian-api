source "https://rubygems.org"

# Ruby version
ruby File.read(".ruby-version").strip

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.4"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Authentication with Devise and JWT
gem "devise", "~> 4.9"
gem "devise-jwt", "~> 0.12"

# Authorization with Pundit
gem "pundit", "~> 2.3"

# Pagination
gem "pagy", "~> 9.0"

# Soft delete
gem "paranoia", "~> 3.0"

# Audit logging
gem "audited", "~> 5.4"

# API documentation
gem "rswag", "~> 2.15"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache and Active Job
gem "solid_cache"
gem "solid_queue"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Load environment variables from .env
gem "dotenv-rails", "~> 3.1"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Testing framework
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.5"
  gem "shoulda-matchers", "~> 6.0"
end

group :development do
  # Generate entity-relationship diagrams (requires Graphviz installed locally)
  gem "rails-erd", require: false
end

# Testing
group :test do
  gem "database_cleaner-active_record", "~> 2.2"
  gem "simplecov", "~> 0.22", require: false
  gem "rspec_junit_formatter", "~> 0.6"
  gem "rspec-html-matchers", "~> 0.10"
end
