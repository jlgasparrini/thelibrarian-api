require 'rails_helper'

RSpec.describe JwtAuthentication, type: :controller do
  controller(ApplicationController) do
    include JwtAuthentication

    def index
      render json: { secret: jwt_secret_key }
    end

    def show
      token = params[:token]
      decoded = decode_jwt_token(token)
      render json: { decoded: decoded }
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'show' => 'anonymous#show'
    end
  end

  describe '.jwt_secret_key (class method)' do
    context 'when JWT_SECRET_KEY env variable is set' do
      it 'returns the environment variable value' do
        allow(ENV).to receive(:[]).with('JWT_SECRET_KEY').and_return('test_secret_key')
        expect(controller.class.jwt_secret_key).to eq('test_secret_key')
      end
    end

    context 'when JWT_SECRET_KEY env variable is not set' do
      it 'falls back to Rails secret_key_base' do
        allow(ENV).to receive(:[]).with('JWT_SECRET_KEY').and_return(nil)
        expect(controller.class.jwt_secret_key).to eq(Rails.application.credentials.secret_key_base)
      end
    end
  end

  describe '#jwt_secret_key (instance method)' do
    it 'calls the class method' do
      allow(controller.class).to receive(:jwt_secret_key).and_return('instance_secret')
      expect(controller.jwt_secret_key).to eq('instance_secret')
    end

    it 'returns the same value as class method' do
      expect(controller.jwt_secret_key).to eq(controller.class.jwt_secret_key)
    end
  end

  describe '#decode_jwt_token' do
    let(:secret_key) { 'test_secret_key' }
    let(:payload) { { 'sub' => 123, 'exp' => (Time.now + 1.hour).to_i } }

    before do
      allow(controller).to receive(:jwt_secret_key).and_return(secret_key)
    end

    context 'with a valid JWT token' do
      let(:valid_token) { JWT.encode(payload, secret_key) }

      it 'successfully decodes the token' do
        result = controller.decode_jwt_token(valid_token)
        expect(result).to be_a(Hash)
        expect(result['sub']).to eq(123)
      end

      it 'returns the payload as a hash' do
        result = controller.decode_jwt_token(valid_token)
        expect(result).to include('sub', 'exp')
      end
    end

    context 'with an invalid JWT token' do
      let(:invalid_token) { 'invalid.jwt.token' }

      it 'returns nil' do
        result = controller.decode_jwt_token(invalid_token)
        expect(result).to be_nil
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error)
        controller.decode_jwt_token(invalid_token)
        expect(Rails.logger).to have_received(:error).with(/JWT Decode Error/)
      end
    end

    context 'with a token signed with wrong secret' do
      let(:wrong_secret_token) { JWT.encode(payload, 'wrong_secret') }

      it 'returns nil' do
        result = controller.decode_jwt_token(wrong_secret_token)
        expect(result).to be_nil
      end

      it 'logs the decode error' do
        allow(Rails.logger).to receive(:error)
        controller.decode_jwt_token(wrong_secret_token)
        expect(Rails.logger).to have_received(:error).with(/JWT Decode Error/)
      end
    end

    context 'with an expired token' do
      let(:expired_payload) { { 'sub' => 123, 'exp' => (Time.now - 1.hour).to_i } }
      let(:expired_token) { JWT.encode(expired_payload, secret_key) }

      it 'returns nil' do
        result = controller.decode_jwt_token(expired_token)
        expect(result).to be_nil
      end

      it 'logs the expiration error' do
        allow(Rails.logger).to receive(:error)
        controller.decode_jwt_token(expired_token)
        expect(Rails.logger).to have_received(:error).with(/JWT Decode Error/)
      end
    end

    context 'with a malformed token' do
      let(:malformed_token) { 'not-a-jwt' }

      it 'returns nil' do
        result = controller.decode_jwt_token(malformed_token)
        expect(result).to be_nil
      end

      it 'handles the decode error gracefully' do
        expect { controller.decode_jwt_token(malformed_token) }.not_to raise_error
      end
    end

    context 'with an empty token' do
      let(:empty_token) { '' }

      it 'returns nil' do
        result = controller.decode_jwt_token(empty_token)
        expect(result).to be_nil
      end
    end

    context 'with nil token' do
      it 'returns nil' do
        result = controller.decode_jwt_token(nil)
        expect(result).to be_nil
      end
    end
  end
end
