# frozen_string_literal: true

RSpec.describe GovukPersonalisation::Session do
  describe "#decode" do
    let(:encoded) { [part1, part2, part3].compact.join("$$") }
    let(:part1) { nil }
    let(:part2) { nil }
    let(:part3) { nil }
    subject(:decoded) { GovukPersonalisation::Session.decode(encoded).compact }

    it "returns an empty hash" do
      expect(decoded).to eq({})
    end

    context "the encoded value has one component" do
      let(:part1) { "foo" }

      it "is decoded to a session header" do
        expect(decoded).to eq({ header: encoded })
      end

      context "it starts with the AUTHENTICITY_TOKEN_PREFIX" do
        let(:part1) { "csrf_#{authenticity_token}" }
        let(:authenticity_token) { "foo" }

        it "is decoded to an authenticity token" do
          expect(decoded).to eq({ authenticity_token: authenticity_token })
        end

        context "there is nothing after the AUTHENTICITY_TOKEN_PREFIX" do
          let(:authenticity_token) { "" }

          it "returns an empty hash" do
            expect(decoded).to eq({})
          end
        end
      end
    end

    context "the encoded value has two components" do
      let(:part1) { "foo" }
      let(:part2) { "bar" }

      it "is decoded to a session header and flash portion" do
        expect(decoded).to eq({ header: part1, flash: to_flash(part2) })
      end

      context "the first part starts with the AUTHENTICITY_TOKEN_PREFIX" do
        let(:part1) { "csrf_#{authenticity_token}" }
        let(:authenticity_token) { "foo" }

        it "is decoded to an authenticity token and a session header" do
          expect(decoded).to eq({ authenticity_token: authenticity_token, header: part2 })
        end

        context "there is nothing after the AUTHENTICITY_TOKEN_PREFIX" do
          let(:authenticity_token) { "" }

          it "is decoded to a session header" do
            expect(decoded).to eq({ header: part2 })
          end
        end
      end
    end

    context "the encoded value has three components" do
      let(:part1) { "foo" }
      let(:part2) { "bar" }
      let(:part3) { "baz" }

      it "is decoded to a session header and a flash portion" do
        expect(decoded).to eq({ header: part2, flash: to_flash(part3) })
      end

      context "the first part starts with the AUTHENTICITY_TOKEN_PREFIX" do
        let(:part1) { "csrf_#{authenticity_token}" }
        let(:authenticity_token) { "foo" }

        it "is decoded to an authenticity token, a session header, and a flash portion" do
          expect(decoded).to eq({ authenticity_token: authenticity_token, header: part2, flash: to_flash(part3) })
        end

        context "there is nothing after the AUTHENTICITY_TOKEN_PREFIX" do
          let(:authenticity_token) { "" }

          it "is decoded to a session header and a flash portion" do
            expect(decoded).to eq({ header: part2, flash: to_flash(part3) })
          end
        end
      end
    end

    def to_flash(str)
      str.split(",").index_with { |_| true }
    end
  end

  describe "#encode" do
    subject(:encoded) { GovukPersonalisation::Session.encode(authenticity_token: authenticity_token, header: header, flash: flash) }
    let(:decoded) { GovukPersonalisation::Session.decode(encoded).compact }
    let(:expected_decoding) { { authenticity_token: authenticity_token, header: header, flash: flash }.compact }

    let(:authenticity_token) { "foo" }
    let(:header) { "bar" }
    let(:flash) { { "baz" => true } }

    it "round-trips through #decode" do
      expect(decoded).to eq(expected_decoding)
    end

    context "the authenticity token is blank" do
      let(:authenticity_token) { nil }

      it "round-trips through #decode" do
        expect(decoded).to eq(expected_decoding)
      end
    end

    context "the header is blank" do
      let(:header) { nil }

      it "blanks the flash" do
        expect(decoded).to eq(expected_decoding.merge(flash: nil).compact)
      end
    end

    context "the flash is blank" do
      let(:flash) { nil }

      it "round-trips through #decode" do
        expect(decoded).to eq(expected_decoding)
      end
    end
  end
end
