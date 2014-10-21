require 'rails_helper'

describe ChannelsController do
  let(:user){ create :user }
  let(:channel_inactive){ create :channel, :status => "inactive", :user => user }
  let(:channel_betting_open){ create :channel, :status => "betting_open", :user => user }
  let(:channel_betting_closed){ create :channel, :status => "betting_closed", :user => user }
  let(:channel){ create :channel, :user => user }
  let(:unrelated_channel){ create :channel }
  
  describe "GET #show" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        before{
          get :show, {:id => channel.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "200" }
      end
      
      context "owned by other user" do
        before{
          get :show, {:id => unrelated_channel.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "200" }
      end
    end
    
    context "logged out" do
      before{
        get :show, {:id => channel.id, :format => :json}
      }
      
      it{ expect(response.code).to eq "200" }
    end
  end
  
  describe "GET #set_inactive" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        context "inactive" do
          before{
            get :set_inactive, {:id => channel_inactive.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
        end
        
        context "betting_open" do
          before{
            get :set_inactive, {:id => channel_betting_open.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
        end
        
        context "betting_closed" do
          before{
            get :set_inactive, {:id => channel_betting_closed.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
        end
      end
      
      context "owned by other user" do
        before{
          get :set_inactive, {:id => unrelated_channel.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "403" }
      end
    end
    
    context "logged out" do
      before{
        get :set_inactive, {:id => channel.id, :format => :json}
      }
      
      it{ expect(response.code).to eq "403" }
    end
  end
  
  describe "GET #open_betting" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        context "inactive" do
          before{
            get :open_betting, {:id => channel_inactive.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
        end
        
        context "betting_open" do
          before{
            get :open_betting, {:id => channel_betting_open.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "betting_closed" do
          before{
            get :open_betting, {:id => channel_betting_closed.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
        end
      end
      
      context "owned by other user" do
        before{
          get :open_betting, {:id => unrelated_channel.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "403" }
      end
    end
    
    context "logged out" do
      before{
        get :open_betting, {:id => channel.id, :format => :json}
      }
      
      it{ expect(response.code).to eq "403" }
    end
  end
  
  describe "GET #close_betting" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        context "inactive" do
          before{
            get :close_betting, {:id => channel_inactive.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "betting_open" do
          before{
            get :close_betting, {:id => channel_betting_open.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
        end
        
        context "betting_closed" do
          before{
            get :close_betting, {:id => channel_betting_closed.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
        end
      end
      
      context "owned by other user" do
        before{
          get :close_betting, {:id => unrelated_channel.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "403" }
      end
    end
    
    context "logged out" do
      before{
        get :close_betting, {:id => channel.id, :format => :json}
      }
      
      it{ expect(response.code).to eq "403" }
    end
  end
  
  describe "GET #complete_betting" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        context "inactive" do
          before{
            get :complete_betting, {:id => channel_inactive.id, :enemy_id => 1, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "betting_open" do
          before{
            get :complete_betting, {:id => channel_betting_open.id, :enemy_id => 1, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "betting_closed" do
          before{
            get :complete_betting, {:id => channel_betting_closed.id, :enemy_id => 1, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
        end
      end
      
      context "owned by other user" do
        before{
          get :complete_betting, {:id => unrelated_channel.id, :enemy_id => 1, :format => :json}
        }
        
        it{ expect(response.code).to eq "403" }
      end
    end
    
    context "logged out" do
      before{
        get :complete_betting, {:id => channel.id, :enemy_id => 1, :format => :json}
      }
      
      it{ expect(response.code).to eq "403" }
    end
  end
end