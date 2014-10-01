class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitch
    @user = User.from_omniauth(request.env["omniauth.auth"])
    
    if @user.persisted?
      sign_in @user #this will throw if @user is not activated
      redirect_to app_path
    end
  end
end