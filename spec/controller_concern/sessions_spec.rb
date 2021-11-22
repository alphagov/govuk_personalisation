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

      it "does not make the response uncacheable" do
        get show_session_path, headers: headers
        expect(response.headers["Cache-Control"]).not_to eq("no-store")
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

      it "does not make the response uncacheable" do
        get show_session_path, headers: headers
        expect(response.headers["Cache-Control"]).not_to eq("no-store")
      end

      context "when there is a flash in the user's session" do
        let(:account_session_header) { "#{session_id}$$flash" }
        let(:session_id) { "foo" }

        it "returns an empty flash in the response" do
          get show_session_path, headers: headers
          expect(response.headers["GOVUK-Account-Session"]).to eq(session_id)
        end

        it "makes the response uncacheable" do
          get show_session_path, headers: headers
          expect(response.headers["Cache-Control"]).to eq("no-store")
        end
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

    it "makes the response uncacheable" do
      get update_session_path, params: { new_session_header: "bar" }
      expect(response.headers["Cache-Control"]).to eq("no-store")
    end

    it "preserves the flash" do
      session_with_flash = "foo$$flash,messages"
      get update_session_path, headers: { "GOVUK-Account-Session" => session_with_flash }, params: { keep_flash: "1" }

      expect(response.headers["GOVUK-Account-Session"]).to eq(session_with_flash)
    end

    it "updates the flash" do
      get update_session_path, headers: { "GOVUK-Account-Session" => "foo$$flash,messages" }, params: { add_to_flash: "new-flash-message" }

      expect(response.headers["GOVUK-Account-Session"]).to eq("foo$$new-flash-message")
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

    it "makes the response uncacheable" do
      get delete_session_path
      expect(response.headers["Cache-Control"]).to eq("no-store")
    end
  end
end
