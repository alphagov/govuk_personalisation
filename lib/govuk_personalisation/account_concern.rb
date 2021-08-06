# frozen_string_literal: true

require "active_support/concern"

module GovukPersonalisation
  module AccountConcern
    extend ActiveSupport::Concern

    ACCOUNT_SESSION_INTERNAL_HEADER_NAME = "HTTP_GOVUK_ACCOUNT_SESSION"
    ACCOUNT_SESSION_HEADER_NAME = "GOVUK-Account-Session"
    ACCOUNT_END_SESSION_HEADER_NAME = "GOVUK-Account-End-Session"
    ACCOUNT_SESSION_DEV_COOKIE_NAME = "govuk_account_session"

    included do
      before_action :fetch_account_session_header
      before_action :set_account_vary_header
      attr_accessor :account_session_header
      attr_reader :account_flash
    end

    def logged_in?
      account_session_header.present?
    end

    def fetch_account_session_header
      session_with_flash =
        if request.headers[ACCOUNT_SESSION_INTERNAL_HEADER_NAME]
          request.headers[ACCOUNT_SESSION_INTERNAL_HEADER_NAME].presence
        elsif Rails.env.development?
          cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME]
        end

      @account_session_header, flash = GovukPersonalisation::Flash.decode_session(session_with_flash)
      @account_flash = (flash || []).index_with { |_| true }
      @new_account_flash = {}

      set_account_session_header unless @account_flash.empty?
    end

    def set_account_vary_header
      response.headers["Vary"] = [response.headers["Vary"], ACCOUNT_SESSION_HEADER_NAME].compact.join(", ")
    end

    def set_account_session_header(govuk_account_session = nil)
      @account_session_header = govuk_account_session if govuk_account_session

      session_with_flash = GovukPersonalisation::Flash.encode_session(@account_session_header, @new_account_flash.keys)

      response.headers[ACCOUNT_SESSION_HEADER_NAME] = session_with_flash
      if Rails.env.development?
        cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME] = {
          value: session_with_flash,
          domain: "dev.gov.uk",
        }
      end
    end

    def logout!
      response.headers[ACCOUNT_END_SESSION_HEADER_NAME] = "1"
      @account_session_header = nil
      if Rails.env.development?
        cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME] = {
          value: "",
          domain: "dev.gov.uk",
          expires: 1.second.ago,
        }
      end
    end

    # Add a message to the flash to return to the user.  This does not
    # change `account_flash`
    #
    # @param message [String] the message to add
    #
    # @return [true, false] whether the message is valid (and so has been added)
    def account_flash_add(message)
      return false unless GovukPersonalisation::Flash.valid_message? message

      @new_account_flash[message] = true
      set_account_session_header
      true
    end

    # Copy all messages from the `account_flash` into the flash to
    # return to the user.
    def account_flash_keep
      @new_account_flash = @account_flash.merge(@new_account_flash)
      set_account_session_header
    end
  end
end
