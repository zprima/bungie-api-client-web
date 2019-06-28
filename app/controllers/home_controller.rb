class HomeController < ApplicationController
  before_action :authenticate
  
  def index
  end

  def refresh
    DestinyProfile.refresh_for(
      user: current_user,
      membership_id: current_membership.membership_id,
      membership_type: current_membership.membership_type
    )
    
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render head: 204 }
    end
  end
end
