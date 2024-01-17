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

  describe "#digital_identity_domain" do
    subject(:url) { described_class.digital_identity_domain("home") }

    it "returns the domain hostname" do
      expect(url).to eq("home.account.gov.uk")
    end

    context "when the DIGITAL_IDENTITY_ENVIRONMENT env var is set" do
      around do |example|
        ClimateControl.modify("DIGITAL_IDENTITY_ENVIRONMENT" => "load-test") do
          example.run
        end
      end

      it "constructs the hostname from the env var" do
        expect(url).to eq("home.load-test.account.gov.uk")
      end
    end

    context "when the GOVUK_ENVIRONMENT env var is set to production" do
      around do |example|
        ClimateControl.modify("GOVUK_ENVIRONMENT" => "production") do
          example.run
        end
      end

      it "returns the domain hostname" do
        expect(url).to eq("home.account.gov.uk")
      end
    end

    context "when the GOVUK_ENVIRONMENT env var is set to an arbitrary value" do
      around do |example|
        ClimateControl.modify("GOVUK_ENVIRONMENT" => "test") do
          example.run
        end
      end

      it "constructs the hostname from the env var" do
        expect(url).to eq("home.test.account.gov.uk")
      end
    end

    # NOTE: staging and integration in One Login are inverted compared
    # to GOV.UK (our staging has to point to their integration and
    # vice versa). Don't try to "fix" the following two tests unless
    # something has explicitly changed!
    context "when the GOVUK_ENVIRONMENT env var is set to staging" do
      around do |example|
        ClimateControl.modify("GOVUK_ENVIRONMENT" => "staging") do
          example.run
        end
      end

      it "returns the domain hostname with integration" do
        expect(url).to eq("home.integration.account.gov.uk")
      end
    end

    context "when the GOVUK_ENVIRONMENT env var is set to integration" do
      around do |example|
        ClimateControl.modify("GOVUK_ENVIRONMENT" => "integration") do
          example.run
        end
      end

      it "returns the domain hostname with staging" do
        expect(url).to eq("home.staging.account.gov.uk")
      end
    end
  end
end
