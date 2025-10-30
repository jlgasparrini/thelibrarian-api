# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Library Management System API',
        version: 'v1',
        description: 'API for managing library books, borrowings, and users with JWT authentication',
        contact: {
          name: 'API Support',
          email: 'support@library.com'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://{defaultHost}',
          description: 'Production server',
          variables: {
            defaultHost: {
              default: 'api.library.com'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token obtained from /api/v1/auth/sign_in'
          }
        },
        schemas: {
          Error: {
            type: :object,
            properties: {
              error: { type: :string }
            },
            required: [ 'error' ]
          },
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string },
              role: { type: :string, enum: [ 'member', 'librarian' ] },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          Book: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              author: { type: :string },
              genre: { type: :string },
              isbn: { type: :string },
              total_copies: { type: :integer },
              available_copies: { type: :integer },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          Borrowing: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              book_id: { type: :integer },
              borrowed_at: { type: :string, format: 'date-time' },
              due_date: { type: :string, format: 'date-time' },
              returned_at: { type: :string, format: 'date-time', nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
