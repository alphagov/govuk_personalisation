# frozen_string-literal: true

module GovukPersonalisation::Flash
  SESSION_SEPARATOR = "$$"
  MESSAGE_SEPARATOR = ","
  MESSAGE_REGEX = /\A[a-zA-Z0-9._-]+\z/

  # Splits the session header into a session value (suitable for using
  # in account-api calls) and flash messages.
  #
  # @param encoded_session [String] the value of the `GOVUK-Account-Session` header
  #
  # @return [Array(String, Array<String>), nil] the session value and the flash messages
  def self.decode_session(encoded_session)
    session_bits = encoded_session&.split(SESSION_SEPARATOR)
    return if session_bits.blank?

    if session_bits.length == 1
      [session_bits[0], []]
    else
      [session_bits[0], session_bits[1].split(MESSAGE_SEPARATOR)]
    end
  end

  # Encodes the session value and a list of flash messages into a
  # session header which can be returned to the user.
  #
  # @param session [String]        the session value
  # @param flash   [Array<String>] the flash messages, which must all be `valid_message?`
  #
  # @return [String] the encoded session header value
  def self.encode_session(session, flash)
    if flash.blank?
      session
    else
      "#{session}#{SESSION_SEPARATOR}#{flash.join(MESSAGE_SEPARATOR)}"
    end
  end

  # Check if a string is valid as a flash message.
  #
  # @param message [String, nil] the flash message
  #
  # @return [true, false] whether the message is valid or not.
  def self.valid_message?(message)
    return false if message.nil?

    message.match? MESSAGE_REGEX
  end
end
