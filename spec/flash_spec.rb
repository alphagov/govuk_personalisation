# frozen_string_literal: true

RSpec.describe GovukPersonalisation::Flash do
  describe "#decode_session" do
    let(:encoded_session) { "" }
    subject(:decoded) { GovukPersonalisation::Flash.decode_session(encoded_session) }

    it "returns nil" do
      expect(decoded).to be_nil
    end

    context "the encoded session has one part" do
      let(:encoded_session) { "session-id" }

      it "returns the session and no flash messages" do
        expect(decoded).to eq([encoded_session, []])
      end
    end

    context "the encoded session has two parts" do
      let(:encoded_session) { "#{session_id}$$#{flash.join(',')}" }
      let(:session_id) { "session-id" }
      let(:flash) { %w[foo bar baz] }

      it "returns the session and the flash messages" do
        expect(decoded).to eq([session_id, flash])
      end

      context "the flash part is empty" do
        let(:flash) { [] }

        it "returns the session and no flash messages" do
          expect(decoded).to eq([session_id, []])
        end
      end
    end
  end

  describe "#encode_session" do
    let(:session) { "session-id" }
    let(:flash) { %w[foo bar baz] }
    subject(:encoded) { GovukPersonalisation::Flash.encode_session(session, flash) }

    it "returns a two-part encoded session" do
      expect(encoded).to eq("#{session}$$#{flash.join(',')}")
    end

    it "round-trips through #decode_session" do
      expect(GovukPersonalisation::Flash.decode_session(encoded)).to eq([session, flash])
    end

    context "the flash is empty" do
      let(:flash) { [] }

      it "returns a one-part encoded session" do
        expect(encoded).to eq(session)
      end
    end

    context "the flash is nil" do
      let(:flash) { nil }

      it "returns a one-part encoded session" do
        expect(encoded).to eq(session)
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
