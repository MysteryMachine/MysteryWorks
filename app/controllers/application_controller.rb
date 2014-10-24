class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::Cookies

  serialization_scope :current_user
  
  # This function is used by OAuth, was copied from wiki
  def new_session_path(scope)
    return new_user_session_path
  end
  
  def logged_in
    !current_user.nil?
  end
  
  def app_path
    ENV["APP_PATH"]
  end
  
  def default_serializer_options
    {root: false}
  end
  
  # Shouldn't do anything, but is here just in case it's used
  # in the background somewhere by OAuth
  def new
    render :nothing => true
  end
  
  def destroy
    sign_out current_user
    render :nothing => true
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    render :nothing => true, :status => 403
  end
end
