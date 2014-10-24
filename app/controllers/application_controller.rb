class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::Cookies

  serialization_scope :current_user
  
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers
  
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
  
  private 
  
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = ENV["ORIGIN"]
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
    headers['Access-Control-Allow-Credentials'] = 'true'
  end

  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = ENV["ORIGIN"]
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
    headers['Access-Control-Max-Age'] = '1728000'
  end
end
