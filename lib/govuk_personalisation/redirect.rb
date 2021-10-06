module GovukPersonalisation::Redirect
  # Builds a URL with additional query parameters
  #
  # Allows for a simple method call to add params on to an existing
  # URL, for instance when adding _ga tracking params to a redirect
  #
  # @param          base_url          [String] The URL to attach additional parameters to
  # @param optional additional_params [Hash{String,Symbol => String}] additional parameters
  #                                   to be added to the URL. If empty, returns the base URL.
  #
  # @return                           [String] a new URL with additional parameters
  def self.build_url(base_url, additional_params = {})
    return base_url if additional_params.empty?

    additional_query = additional_params.to_a.map { |param| param.join("=") }.join("&")

    if base_url.include? "?"
      "#{base_url}&#{additional_query}"
    else
      "#{base_url}?#{additional_query}"
    end
  end
end
