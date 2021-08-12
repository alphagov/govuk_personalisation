# frozen_string_literal: true

RSpec.describe GovukPersonalisation::Flash do
  describe "#decode" do
    let(:encoded) { "" }
    subject(:decoded) { GovukPersonalisation::Flash.decode(encoded) }

    it "returns nil" do
      expect(decoded).to be_nil
    end

    context "there are encoded messages" do
      let(:encoded) { messages.join(",") }
      let(:messages) { %w[foo bar baz] }

      it "returns a hash of messages" do
        expect(decoded).to eq(messages.index_with { |_| true })
      end
    end
  end

  describe "#encode" do
    let(:messages) { %w[foo bar baz] }
    let(:flash) { messages.index_with { |_| true } }
    subject(:encoded) { GovukPersonalisation::Flash.encode(flash) }

    it "encodes the messages" do
      expect(encoded).to eq(messages.join(","))
    end

    it "round-trips through #decode" do
      expect(GovukPersonalisation::Flash.decode(encoded)).to eq(flash)
    end

    context "the flash is empty" do
      let(:flash) { [] }

      it "returns nil" do
        expect(encoded).to eq(nil)
      end
    end

    context "the flash is nil" do
      let(:flash) { nil }

      it "returns nil" do
        expect(encoded).to eq(nil)
      end
    end
  end

  describe "#valid_message?" do
    it "allows messages with alphanumeric characters, hyphens, underscores, and dots" do
      expect(GovukPersonalisation::Flash.valid_message?("123-Message-With-_-And-.-In-It-456")).to be(true)
    end

    it "rejects messages containing '$$'" do
      expect(GovukPersonalisation::Flash.valid_message?("message-with-$$-in-it")).to be(false)
    end

    it "rejects messages containing ','" do
      expect(GovukPersonalisation::Flash.valid_message?("message-with-,-in-it")).to be(false)
    end

    it "rejects the nil message" do
      expect(GovukPersonalisation::Flash.valid_message?(nil)).to be(false)
    end
  end
end
