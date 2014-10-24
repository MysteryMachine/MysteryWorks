class UsersController < UncachedController
  respond_to :json
  
  def user
    if current_user.nil?
      render :nothing => true, :status => 400
    else
      render :json => current_user, :status => 200
    end
  end
end