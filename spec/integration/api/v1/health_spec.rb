require 'swagger_helper'

RSpec.describe 'api/v1/health', type: :request do
  path '/api/v1/health' do
    get('Health check') do
      tags 'Health'
      produces 'application/json'
      description 'Returns the health status of the API. No authentication required.'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            status: { type: :string, enum: [ 'ok' ] },
            timestamp: { type: :string, format: :datetime },
            version: { type: :string }
          },
          required: [ 'status' ]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('ok')
        end
      end
    end
  end
end
