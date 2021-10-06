# frozen_string_literal: true

RSpec.describe "Redirects", type: :request do
  describe "GET /show" do
    it "redirects to the base url if no parameters are provided" do
      get show_redirect_path
      expect(response).to redirect_to("https://example.com?keep=this")
    end

    it "appends the _ga parameter to the redirected URL" do
      get show_redirect_path({ _ga: "abc123" })
      expect(response).to redirect_to("https://example.com?keep=this&_ga=abc123")
    end

    it "appends the cookie_consent parameter to the redirected URL" do
      get show_redirect_path({ cookie_consent: "reject" })
      expect(response).to redirect_to("https://example.com?keep=this&cookie_consent=reject")
    end

    it "appends both parameters to the redirected URL" do
      get show_redirect_path({ _ga: "abc123", cookie_consent: "reject" })
      expect(response).to redirect_to("https://example.com?keep=this&_ga=abc123&cookie_consent=reject")
    end

    it "does not append unpermitted parameters to the redirected URL" do
      get show_redirect_path({ _ga: "abc123", evil_admin_access: true })
      expect(response).to redirect_to("https://example.com?keep=this&_ga=abc123")
    end
  end
end
