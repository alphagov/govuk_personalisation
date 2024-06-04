class SessionsController < ApplicationController
  include GovukPersonalisation::ControllerConcern

  def show
    render json: { logged_in: logged_in?, account_session_header: }
  end

  def update
    set_account_session_header params[:new_session_header]
    account_flash_keep if params[:keep_flash]
    account_flash_add params[:add_to_flash]
    head :no_content
  end

  def delete
    logout!
    head :no_content
  end
end
