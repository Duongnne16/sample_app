class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :load_user, only: %i(show edit update destroy following followers)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  # GET /:locale/users/:id
  def show
    @pagy, @microposts = pagy(@user.microposts.includes(:user).newest)
  end

  # GET /:locale/signup
  def new
    @user = User.new
  end

  # POST /:locale/signup
  def create
    @user = User.new(user_params)

    if @user.save
      @user.send_activation_email
      flash[:info] = t(".check_email") # users.create.check_email
      redirect_to root_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /:locale/users/:id/edit
  def edit; end

  # PATCH/PUT /:locale/users/:id
  def update
    if @user.update(user_params)
      flash[:success] = t(".success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @pagy, @users = pagy(User.ordered)
  end

  def destroy
    if @user.destroy
      flash[:success] = t(".success") # users.destroy.success
    else
      flash[:error] = t(".error") # users.destroy.error
    end
    redirect_to users_path
  end

  def following
    @title = t("users.show_follow.following")
    @pagy, @users = pagy(@user.following)
    render :show_follow
  end

  def followers
    @title = t("users.show_follow.followers")
    @pagy, @users = pagy(@user.followers)
    render :show_follow
  end

  private

  def admin_user
    return if current_user&.admin?

    flash[:danger] = t("users.not_authorized")
    redirect_to root_path
  end

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:danger] = t("users.not_found")
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(User::USER_PARAMS)
  end

  def correct_user
    return if current_user?(@user)

    flash[:error] = t("users.not_authorized")
    redirect_to root_path, status: :see_other
  end
end
