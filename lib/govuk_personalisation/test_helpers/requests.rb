module GovukPersonalisation
  module TestHelpers
    module Requests
      # Set the `GOVUK-Account-Session` request header.
      #
      # @param session_id [String]             the session identifier
      # @param flash      [Array<String>, nil] the flash messages
      def mock_logged_in_session(session_id = "placeholder", flash = nil)
        request.headers["GOVUK-Account-Session"] = GovukPersonalisation::Flash.encode_session(session_id, flash)
      end
    end
  end
end
