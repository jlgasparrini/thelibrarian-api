module JwtAuthentication
  extend ActiveSupport::Concern

  class_methods do
    def jwt_secret_key
      ENV["JWT_SECRET_KEY"] || Rails.application.credentials.secret_key_base
    end
  end

  def jwt_secret_key
    self.class.jwt_secret_key
  end

  def decode_jwt_token(token)
    JWT.decode(token, jwt_secret_key).first
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT Decode Error: #{e.message}")
    nil
  end
end
