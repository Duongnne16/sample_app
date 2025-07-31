class PasswordResetsController < ApplicationController
  before_action :load_user, only: %i(create edit update)
  before_action :valid_user, :check_expiration,
                only: %i(edit update)
  before_action :check_blank_password, only: :update

  # GET /password_resets/new
  def new; end

  # POST /password_resets
  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t(".email_sent")
    redirect_to root_path
  end

  # GET /password_resets/:id/edit?email=...
  def edit; end

  # PATCH /password_resets/:id?email=...
  def update
    if @user.update(user_params.merge(reset_digest: nil))
      flash[:success] = t(".password_reset_success")
      UserMailer.password_changed(@user).deliver_now
      redirect_to login_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def check_blank_password
    return unless user_params[:password].empty?

    @user.errors.add :password, t(".blank_password")
    render :edit, status: :unprocessable_entity
  end

  def load_user
    email = params.dig(:password_reset, :email)&.downcase ||
            params[:email]&.downcase
    @user = User.find_by(email:)
    return if @user

    flash[:danger] = t(".user_not_found")
    redirect_to root_path
  end

  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t(".invalid_user")
    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".password_reset_expired")
    redirect_to new_password_reset_path
  end
end
