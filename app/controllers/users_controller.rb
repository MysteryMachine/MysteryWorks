class UsersController < ApplicationController
  respond_to :json
  
  def user
    if current_user.nil?
      redirect_to "/users/auth/twitch"
    else
      render :json => current_user
    end
  end
end