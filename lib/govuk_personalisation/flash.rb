# frozen_string-literal: true

module GovukPersonalisation::Flash
  SEPARATOR = ","
  REGEX = /\A[a-zA-Z0-9._\-]+\z/.freeze

  # Splits an encoded string of flash messages into an object with
  # keys being messages and values being `true`.
  #
  # @param encoded_session [String] the encoded flash messages
  #
  # @return [Hash<String, true>] the flash messages
  def self.decode(encoded_flash)
    messages = encoded_flash&.split(SEPARATOR) || []
    return if messages.blank?

    messages.index_with { |_| true }
  end

  # Encodes a flash hash into a string which can be embedded into the
  # session header.
  #
  # @param flash [Hash<String, true>] the flash messages, which must all be `valid_message?`
  #
  # @return [String] the flash value
  def self.encode(flash)
    return if flash.blank?

    flash.keys.join(SEPARATOR)
  end

  # Check if a string is valid as a flash message.
  #
  # @param message [String, nil] the flash message
  #
  # @return [true, false] whether the message is valid or not.
  def self.valid_message?(message)
    return false if message.nil?

    message.match? REGEX
  end
end
