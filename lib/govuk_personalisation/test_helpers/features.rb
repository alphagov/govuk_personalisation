module GovukPersonalisation
  module TestHelpers
    module Features
      # Set the `GOVUK-Account-Session` request header in the page
      # driver.
      #
      # @param session_id [String]             the session identifier
      # @param flash      [Array<String>, nil] the flash messages
      def mock_logged_in_session(session_id = "placeholder", flash = nil)
        page.driver.header("GOVUK-Account-Session", GovukPersonalisation::Flash.encode_session(session_id, flash))
      end
    end
  end
end
