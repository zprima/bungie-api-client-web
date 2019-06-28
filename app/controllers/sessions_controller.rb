class SessionsController < ApplicationController
  layout 'session'

  def new
    @login_url = BungieAuthService.get_login_link
  end

  def create
    if params[:error].present?
      flash[:error] = params[:error_description]
      return redirect_to root_path 
    end

    auth_info = BungieAuthService.get_access_token(params[:code])
    if auth_info.key?(:error)
      flash[:error] = auth_info[:error]
      return redirect_to root_path
    end

    @user = User.find_or_create_from_auth(auth_info)
    session[:user_membership_id] = @user.membership_id

    response = BungieApiService.new(@user).get_memberships_for_current_user()
    BungieGeneralUser.prepare_for(
      membership_id: @user.membership_id, 
      data: response["Response"]["bungieNetUser"]
    )
    DestinyMembership.prepare_for(
      membership_id: @user.membership_id, 
      data: response["Response"]["destinyMemberships"]
    )

    redirect_to root_path
  end

  def destroy
    session[:user_membership_id] = nil
  	redirect_to root_path
  end
end
