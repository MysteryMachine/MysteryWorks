class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::Cookies
  
  def new_session_path(scope)
    return new_user_session_path
  end
  
  def app_path
    ENV["APP_PATH"]
  end
  
  def new
    render :json, :nothing => true
  end
  
  def destroy
    render :json, :nothing => true
  end
end
