require 'rails_helper'

RSpec.describe "Routing", type: :request do
  describe "Root path" do
    it "redirects to API documentation" do
      get "/"
      expect(response).to redirect_to("/api-docs")
    end
  end

  describe "404 handling" do
    it "redirects non-existent routes to API documentation" do
      get "/this-does-not-exist"
      expect(response).to redirect_to("/api-docs")
    end

    it "redirects invalid API paths to API documentation" do
      get "/api/v1/invalid-endpoint"
      expect(response).to redirect_to("/api-docs")
    end

    it "redirects deeply nested invalid paths to API documentation" do
      get "/some/random/path/that/does/not/exist"
      expect(response).to redirect_to("/api-docs")
    end
  end

  describe "Valid routes" do
    it "does not redirect valid health endpoint" do
      get "/api/v1/health"
      expect(response).to have_http_status(:ok)
      expect(response).not_to be_redirect
    end

    it "does not redirect valid up endpoint" do
      get "/up"
      expect(response).to have_http_status(:ok)
      expect(response).not_to be_redirect
    end
  end
end
