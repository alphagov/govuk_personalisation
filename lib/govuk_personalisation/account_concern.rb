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
    end

    def logged_in?
      account_session_header.present?
    end

    def fetch_account_session_header
      @account_session_header =
        if request.headers[ACCOUNT_SESSION_INTERNAL_HEADER_NAME]
          request.headers[ACCOUNT_SESSION_INTERNAL_HEADER_NAME].presence
        elsif Rails.env.development?
          cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME]
        end
    end

    def set_account_vary_header
      response.headers["Vary"] = [response.headers["Vary"], ACCOUNT_SESSION_HEADER_NAME].compact.join(", ")
    end

    def set_account_session_header(govuk_account_session = nil)
      @account_session_header = govuk_account_session if govuk_account_session
      response.headers[ACCOUNT_SESSION_HEADER_NAME] = @account_session_header
      if Rails.env.development?
        cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME] = {
          value: @account_session_header,
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
  end
end
