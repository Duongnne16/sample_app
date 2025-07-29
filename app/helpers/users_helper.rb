module UsersHelper
  # Returns the Gravatar for the given user.
  def gravatar_for user, options = {size: 80}
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options[:size]
    default_url = "identicon" # fallback if user does not have a gravatar
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=#{default_url}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  def gender_text user
    I18n.t("users.genders.#{user.gender}")
  end

  def gender_options
    User.genders.keys.map {|g| [I18n.t("users.genders.#{g}"), g]}
  end

  def can_destroy_user? user
    current_user&.admin? && !current_user?(user)
  end
end
