module GovukPersonalisation
  module TestHelpers
    module Requests
      def mock_logged_in_session(value = "placeholder")
        request.headers["GOVUK-Account-Session"] = value
      end
    end
  end
end
