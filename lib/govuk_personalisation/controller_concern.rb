# frozen_string_literal: true

require "active_support/concern"

module GovukPersonalisation
  module ControllerConcern
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

    # Read the `GOVUK-Account-Session` request header and set the
    # `@account_session_header` and `@account_flash` variables.  Also
    # sets a response header with an empty flash if there is a flash
    # in the request.
    #
    # This is called as a `before_action`
    #
    # This should not be called after either of the
    # `@govuk_account_session` or flash to return to the user have
    # been changed, as those changes will be overwritten.
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

    # Set the `Vary: GOVUK-Account-Session` response header.
    #
    # This is called as a `before_action`, to ensure that pages
    # rendered using one user's session are not served to another by
    # our CDN.  You should only skip this action if you are certain
    # that the response does not include any personalisation, or if
    # you prevent caching in some other way (for example, with
    # `Cache-Control: no-store`).
    def set_account_vary_header
      response.headers["Vary"] = [response.headers["Vary"], ACCOUNT_SESSION_HEADER_NAME].compact.join(", ")
    end

    # Check if the user has a session.
    #
    # This does not call account-api to verify that the session is
    # valid, but an invalid session would not allow a user to access
    # any personal data anyway.
    #
    # @return [true, false] whether the user has a session
    def logged_in?
      account_session_header.present?
    end

    # Set a new session header.
    #
    # This should be called after any API call to account-api which
    # returns a new session value.  This is called automatically after
    # updating the flash with `account_flash_add` or
    # `account_flash_keep`
    #
    # Calling this after calling `logout!` will not prevent the user
    # from being logged out.
    #
    # @param govuk_account_session [String, nil] the new session identifier
    def set_account_session_header(govuk_account_session = nil)
      @account_session_header = govuk_account_session if govuk_account_session

      session_with_flash = GovukPersonalisation::Flash.encode_session(@account_session_header, @new_account_flash.keys)

      response.headers[ACCOUNT_SESSION_HEADER_NAME] = session_with_flash
      response.headers["Cache-Control"] = "no-store"

      if Rails.env.development?
        cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME] = {
          value: session_with_flash,
          domain: "dev.gov.uk",
        }
      end
    end

    # Clear the `@account_session_header` and set the logout response
    # header.
    def logout!
      response.headers[ACCOUNT_END_SESSION_HEADER_NAME] = "1"
      response.headers["Cache-Control"] = "no-store"

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

    # Redirect to a URL adding parameters necessary for cross-domain analytics
    # and cookie consent
    #
    # @param url [String] The URL to redirect to
    def redirect_with_analytics(url, allow_other_host: true)
      redirect_to(url_with_analytics(url), allow_other_host: allow_other_host)
    end

    # Build a URL adding parameters necessary for cross-domain analytics
    # and cookie consent
    #
    # @param url [String] The URL
    def url_with_analytics(url)
      GovukPersonalisation::Redirect.build_url(url, params.permit(:_ga, :cookie_consent).to_h)
    end
  end
end
