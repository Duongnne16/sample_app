class MicropostsController < ApplicationController
  before_action :correct_user_micropost, only: :destroy
  before_action :logged_in_user, only: %i(create destroy)

  MICROPOST_PERMIT_PARAMS = %i(content image).freeze

  # POST /microposts
  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = t(".created")
      redirect_to root_path
    else
      @pagy, @feed_items = pagy(current_user.feed)
      render "static_pages/home", status: :unprocessable_entity
    end
  end

  # DELETE /microposts/:id
  def destroy
    if @micropost.destroy
      flash[:success] = t(".deleted")
    else
      flash[:danger] = t(".delete_failed")
    end
    redirect_to request.referer || root_url
  end

  # GET /microposts
  def index
    @microposts = Micropost.recent
  end

  private
  def micropost_params
    params.require(:micropost).permit(MICROPOST_PERMIT_PARAMS)
  end

  def correct_user_micropost
    @micropost = current_user.microposts.find_by(id: params[:id])
    return if @micropost

    flash[:danger] = t(".invalid")
    redirect_to request.referer || root_url
  end
end
