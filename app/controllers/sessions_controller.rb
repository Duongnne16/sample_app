class SessionsController < ApplicationController
  before_action :find_user, only: [:create]
  before_action :check_authentication, only: [:create]
  before_action :check_authentication, only: [:create]

  REMEMBER_ME_CHECKED = "1".freeze

  # GET /:locale/login
  def new; end

  # POST /:locale/login
  def create
    login_success(@user)
  end

  # DELETE /:locale/logout
  def destroy
    log_out
    redirect_to root_url, status: :see_other, notice: t(".logout_success")
  end

  private

  def find_user
    @user = User.find_by(email: session_params[:email]&.downcase)
    return if @user.present?

    flash.now[:danger] = t(".user_not_found")
    render :new, status: :unprocessable_entity
  end

  def check_authentication
    return if @user.authenticate(session_params[:password])

    flash.now[:danger] = t(".invalid_email_password_combination")
    render :new, status: :unprocessable_entity
  end

  def check_activation
    return if @user.activated?

    flash[:warning] = t(".account_not_activated")
    redirect_to root_url
  end

  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end

  def login_success user
    reset_session
    log_in user
    remember_option user
    redirect_to user, notice: t(".login_success")
  end

  def remember_option user
    if session_params[:remember_me] == REMEMBER_ME_CHECKED
      remember(user)
    else
      forget(user)
    end
  end
end
