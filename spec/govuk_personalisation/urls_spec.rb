require "climate_control"

RSpec.describe GovukPersonalisation::Urls do
  describe "#find_govuk_url" do
    subject(:url) { described_class.find_govuk_url(var: var, application: application, path: path) }

    let(:var) { "TEST" }
    let(:application) { "test-frontend-app" }
    let(:path) { "/account/path" }

    it "constructs a URL based on the website root" do
      expect(url).to eq("#{Plek.new.website_root}#{path}")
    end

    context "when the env var is set" do
      around do |example|
        ClimateControl.modify("GOVUK_PERSONALISATION_#{var}_URI" => env_var_uri) do
          example.run
        end
      end

      let(:env_var_uri) { "http://govuk-personalisation-uri/foo/bar" }

      it "uses the URL from the env var" do
        expect(url).to eq(env_var_uri)
      end
    end

    context "when running in development mode" do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it "constructs a URL based on the application" do
        expect(url).to eq("#{Plek.find(application)}#{path}")
      end
    end
  end

  describe "#find_external_url" do
    subject(:url) { described_class.find_external_url(var: var, url: given_url) }

    let(:var) { "TEST" }
    let(:given_url) { "https://www.example.com" }

    it "uses the given URL" do
      expect(url).to eq(given_url)
    end

    context "when the env var is set" do
      around do |example|
        ClimateControl.modify("GOVUK_PERSONALISATION_#{var}_URI" => env_var_uri) do
          example.run
        end
      end

      let(:env_var_uri) { "http://govuk-personalisation-uri/foo/bar" }

      it "uses the URL from the env var" do
        expect(url).to eq(env_var_uri)
      end
    end
  end
end
