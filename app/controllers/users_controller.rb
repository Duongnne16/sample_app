class UsersController < ApplicationController
  before_action :load_user, only: :show

  # GET /:locale/users/:id
  def show; end

  # GET /:locale/signup
  def new
    @user = User.new
  end

  # POST /:locale/signup
  def create
    @user = User.new user_params

    if @user.save
      reset_session
      log_in @user
      flash[:success] = t(".success")
      redirect_to @user, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t("users.not_found")
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(User::USER_PARAMS)
  end
end
