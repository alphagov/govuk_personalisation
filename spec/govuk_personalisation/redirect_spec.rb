RSpec.describe GovukPersonalisation::Redirect do
  describe "#build_url" do
    subject(:url) { described_class.build_url(base_url, additional_params) }

    let(:base_url) { "https://test.gov.uk/thing?param&param-with-key=test" }
    let(:additional_params) { {} }

    context "with a single additional parameter" do
      let(:additional_params) { { _ga: "abc123" } }

      it "adds the parameter and maintains the existing base_url" do
        expect(url).to eq("#{base_url}&_ga=abc123")
      end
    end

    context "with multiple additional parameters" do
      let(:additional_params) { { _ga: "abc123", cookie_consent: "accept" } }

      it "adds the parameters and maintains the existing base_url" do
        expect(url).to eq("#{base_url}&_ga=abc123&cookie_consent=accept")
      end
    end

    context "with duplicate parameters in the base_url" do
      let(:base_url) { "https://test.gov.uk/thing?param=123&param=abc" }
      let(:additional_params) { { _ga: "abc123", cookie_consent: "accept" } }

      it "adds the parameters and maintains the existing base_url" do
        expect(url).to eq("#{base_url}&_ga=abc123&cookie_consent=accept")
      end
    end

    it "redirects to the base url if no parameters are provided" do
      url = described_class.build_url(base_url)
      expect(url).to eq(base_url.to_s)
    end
  end
end
