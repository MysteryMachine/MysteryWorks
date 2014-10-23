require 'rails_helper'

describe UsersController do
  let(:user){create :user}
  
  describe "GET #user" do
    context "user" do
      before{
        sign_in user
        get :user, :format => :json
      }
      
      it{ expect(response.code).to eq "200" }
      it{ expect(JSON.parse(response.body)["channel_id"]).to eq user.channel_id }
    end
    
    context "logged out" do
      before{
        get :user, :format => :json
      }
      
      it{ expect(response.code).to eq "302" }
    end
  end
end