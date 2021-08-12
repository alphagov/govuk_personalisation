# frozen_string-literal: true

module GovukPersonalisation::Session
  SEPARATOR = "$$"
  AUTHENTICITY_TOKEN_PREFIX = "csrf_"

  # Splits the session header into components.
  #
  # After splitting by `FRAGMENT_SEPARATOR`, valid encodings are:
  #
  # - 0 components: `[                                 ]`
  # - 1 component:  `[authenticity_token               ]`
  # -               `[                    header       ]`
  # - 2 components: `[authenticity_token, header       ]`
  # -               `[                    header, flash]`
  # - 3 components: `[authenticity_token, header, flash]`
  #
  # @param encoded_session [String] the value of the `GOVUK-Account-Session` header
  #
  # @return [Hash] the authenticity token, header for account-api, and
  # flash messages; if there is a header for account-api, then the
  # user is logged in.
  def self.decode(encoded_session)
    session_bits = encoded_session&.split(SEPARATOR)&.map(&:presence)
    return {} if session_bits.blank?

    has_authenticity_token, authenticity_token =
      if session_bits[0].start_with? AUTHENTICITY_TOKEN_PREFIX
        [true, session_bits[0].delete_prefix(AUTHENTICITY_TOKEN_PREFIX).presence]
      else
        [false, nil]
      end

    case session_bits.length
    when 1
      if has_authenticity_token
        {
          authenticity_token: authenticity_token,
        }
      else
        {
          header: session_bits[0],
        }
      end
    when 2
      if has_authenticity_token
        {
          authenticity_token: authenticity_token,
          header: session_bits[1],
        }
      else
        {
          header: session_bits[0],
          flash: GovukPersonalisation::Flash.decode(session_bits[1]),
        }
      end
    else
      {
        authenticity_token: authenticity_token,
        header: session_bits[1],
        flash: GovukPersonalisation::Flash.decode(session_bits[2]),
      }
    end
  end

  # Encodes the session value and a list of flash messages into a
  # session header which can be returned to the user.
  #
  # @param header             [String, nil]             the session value
  # @param authenticity_token [String, nil]             an arbitrary authenticity token value
  # @param flash              [Hash<String, true>, nil] the flash messages, which must all be `Flash.valid_message?`
  #
  # @return [String, nil] the encoded session header value
  def self.encode(authenticity_token: nil, header: nil, flash: nil)
    encoded_authenticity_token =
      if authenticity_token.blank?
        nil
      else
        "#{AUTHENTICITY_TOKEN_PREFIX}#{authenticity_token}"
      end

    encoded_flash =
      if header.blank? || flash.blank?
        nil
      else
        GovukPersonalisation::Flash.encode(flash)
      end

    [encoded_authenticity_token, header, encoded_flash].compact.join(SEPARATOR)
  end
end
