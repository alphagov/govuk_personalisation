class RedirectsController < ApplicationController
  include GovukPersonalisation::ControllerConcern

  def show
    redirect_with_analytics("https://example.com?keep=this")
  end
end
