class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :current_bungie_user
  helper_method :current_membership
  helper_method :current_character_id
  helper_method :current_character

  def authenticate
  	redirect_to :login unless user_signed_in?
  end

  def current_user
  	@current_user ||= User.find_by(membership_id: session[:user_membership_id]) if session[:user_membership_id]
  end

  def user_signed_in?
  	current_user.present?
  end

  def current_bungie_user
    @current_bungie_user ||= BungieGeneralUser.find_by(membership_id: current_user.membership_id)
  end

  def current_membership
    @current_membership ||= DestinyMembership.find_by(
      bungie_membership_id: current_user.membership_id,
      membership_id: session[:membership_id]
    ) || DestinyMembership.where(bungie_membership_id: current_user.membership_id).first
  end

  def current_character_id
    @current_character_id = session[:character_id] ||
      DestinyProfile.for(current_user).characters.first.first
  end

  def current_character
    @current_character ||= DestinyProfile.for(current_user).characters[current_character_id]
  end
end
