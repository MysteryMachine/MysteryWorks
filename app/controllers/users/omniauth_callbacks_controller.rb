class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitch
    @user = User.from_omniauth(request.env["omniauth.auth"])
    
    if @user.persisted?
      sign_in @user #this will throw if @user is not activated
      if request.env['omniauth.origin']
        redirect_to app_path + "/#?channel=#{request.env['omniauth.origin']}"
      else
        redirect_to app_path
      end
    end
  end
end