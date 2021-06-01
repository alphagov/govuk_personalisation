class SessionsController < ApplicationController
  include GovukPersonalisation::AccountConcern

  def show
    render json: { logged_in: logged_in?, account_session_header: account_session_header }
  end

  def update
    set_account_session_header params[:new_session_header]
    head :no_content
  end

  def delete
    logout!
    head :no_content
  end
end
