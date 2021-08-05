module GovukPersonalisation
  module TestHelpers
    module Requests
      def mock_logged_in_session(value = "placeholder", flash = nil)
        request.headers["GOVUK-Account-Session"] = GovukPersonalisation::Flash.encode_session(value, flash)
      end
    end
  end
end
