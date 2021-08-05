module GovukPersonalisation
  module TestHelpers
    module Features
      def mock_logged_in_session(value = "placeholder", flash = nil)
        page.driver.header("GOVUK-Account-Session", GovukPersonalisation::Flash.encode_session(value, flash))
      end
    end
  end
end
