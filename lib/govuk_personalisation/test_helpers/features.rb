module GovukPersonalisation
  module TestHelpers
    module Features
      def mock_logged_in_session(value = "placeholder")
        page.driver.header("GOVUK-Account-Session", value)
      end
    end
  end
end
