class UsersController < ApplicationController
  def show
    @user = User.find_by id: params[:id]
    return if @user
        
    flash[:warning] = t("users.notice.not_found")
    redirect_to root_path
  end
end
