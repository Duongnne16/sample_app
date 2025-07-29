class SessionsController < ApplicationController
  before_action :load_user, only: [:create]
  before_action :check_authentication, only: [:create]
  # GET /:locale/login
  def new; end

  # POST /:locale/login
  def create
    reset_session
    log_in @user
    redirect_to @user, notice: t(".login_success")
  end

  # DELETE /:locale/logout
  def destroy
    log_out
    redirect_to root_url, status: :see_other, notice: t(".logout_success")
  end

  private
  def load_user
    @user = User.find_by(email: params.dig(:session, :email)&.downcase)
    return if @user

    flash.now[:danger] = t(".invalid_email_password_combination")
    render :new, status: :unprocessable_entity and return
  end

  def check_authentication
    return if @user&.authenticate(params.dig(:session, :password))

    flash.now[:danger] = t(".invalid_email_password_combination")
    render :new, status: :unprocessable_entity and return
  end
end
