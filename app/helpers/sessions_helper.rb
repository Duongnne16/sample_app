module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  # Returns the user corresponding to the remember token in cookies.
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      load_user_from_cookies(user_id)
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    current_user.present?
  end

  # Logs out the current user.
  def log_out
    forget current_user
    reset_session
    @current_user = nil
  end

  # Remembers the user in a persistent session.
  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forgets a persistent session.
  def forget user
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  private

  # Loads user from cookies and logs in if authenticated.
  def load_user_from_cookies user_id
    user = User.find_by(id: user_id)
    return if user.nil? ||
              !user.authenticated?(:remember, cookies[:remember_token])

    log_in(user)
    @current_user = user
  end

  # Returns true if the given user is the current user, false otherwise.
  def current_user? user
    user == current_user
  end

  # Store the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
