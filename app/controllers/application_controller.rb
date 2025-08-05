class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pagy::Backend

  before_action :set_locale

  def set_locale
    I18n.locale =
      if params[:locale].present? &&
         I18n.available_locales.map(&:to_s).include?(params[:locale])
        params[:locale]
      else
        I18n.default_locale
      end
  end

  def default_url_options
    {locale: I18n.locale}
  end

  private
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t("users.login_required")
    redirect_to login_path, status: :see_other
  end
end
