class AccountActivationsController < ApplicationController
  before_action :load_user, only: :edit
  before_action :valid_user, only: :edit
  before_action :check_activation, only: :edit

  # GET /account_activations/:id/edit?email=:email
  def edit
    @user.activate
    log_in @user
    flash[:success] = t(".success")
    redirect_to @user
  end

  private

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t(".invalid_link")
    redirect_to root_url
  end

  def valid_user
    return if @user.authenticated?(:activation, params[:id])

    flash[:danger] = t(".invalid_link")
    redirect_to root_url
  end

  def check_activation
    return if !@user.activated

    flash[:info] = t(".already_activated")
    redirect_to root_url
  end
end
