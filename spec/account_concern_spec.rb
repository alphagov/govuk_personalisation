# frozen_string_literal: true

RSpec.describe "Sessions", type: :request do
  describe "GET /show" do
    let(:response_body) { JSON.parse(response.body) }

    context "when the user is not logged in" do
      let(:headers) { {} }

      it "shows the logged_in status and the 'GOVUK-Account-Session' header value" do
        get show_session_path, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response_body).to eq("logged_in" => false, "account_session_header" => nil)
        expect(response.headers["Vary"]).to eq("GOVUK-Account-Session")
      end
    end

    context "when the user is logged in" do
      let(:account_session_header) { "foo" }
      let(:headers) { { "GOVUK-Account-Session" => account_session_header } }

      it "shows the logged_in status and the 'GOVUK-Account-Session' header value" do
        get show_session_path, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response_body).to eq("logged_in" => true, "account_session_header" => account_session_header)
        expect(response.headers["Vary"]).to eq("GOVUK-Account-Session")
      end
    end
  end

  describe "GET /update" do
    it "sets the 'GOVUK-Account-Session' header" do
      get update_session_path, params: { new_session_header: "bar" }

      expect(response).to have_http_status(:no_content)
      expect(response.headers["GOVUK-Account-Session"]).to eq("bar")
      expect(response.headers["Vary"]).to eq("GOVUK-Account-Session")
      expect(response.body.blank?)
    end
  end

  describe "GET /delete" do
    it "sets the 'GOVUK-Account-End-Session' header" do
      get delete_session_path

      expect(response).to have_http_status(:no_content)
      expect(response.headers["GOVUK-Account-End-Session"]).to eq("1")
      expect(response.headers["Vary"]).to eq("GOVUK-Account-Session")
      expect(response.body.blank?)
    end
  end
end
