require 'rails_helper'

describe ChannelAccountsController do
  let(:user){ create :user }
  let(:channel_account_inactive){ create :channel_account, :status => "inactive", :user => user }
  let(:channel_account_donating){ create :channel_account, :status => "donating_blood", :user => user }
  let(:channel_account_resting){ create :channel_account, :status => "resting", :user => user }
  let(:channel_account_betting){ create :channel_account, :status => "betting", :user => user }
  let(:channel_account){ create :channel_account, :user => user }
  let(:unrelated_channel_account){ create :channel_account }
  
  describe "GET #show" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        before{
          get :show, {:id => channel_account.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "200" }
      end
      
      context "owned by other user" do
        before{
          get :show, {:id => unrelated_channel_account.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "200" }
      end
    end
    
    context "logged out" do
      before{
        get :show, {:id => channel_account.id, :format => :json}
      }
      
      it{ expect(response.code).to eq "200" }
    end
  end
  
  describe "GET #rest" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        context "inactive" do
          before{
            expect{ 
              get :rest, {:id => channel_account_inactive.id, :format => :json}
            }.to change{ channel_account_inactive.reload.status }.to("resting")
          }
          
          it{ expect(response.code).to eq "200" }
        end
        
        context "donating_blood" do
          before{
            expect{ 
              get :rest, {:id => channel_account_donating.id, :format => :json}
            }.not_to change{ channel_account_donating.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "resting" do
          before{
            expect{ 
              get :rest, {:id => channel_account_resting.id, :format => :json}
            }.not_to change{ channel_account_resting.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "betting" do
          before{
            expect{ 
              get :rest, {:id => channel_account_betting.id, :format => :json}
            }.not_to change{ channel_account_betting.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
      end
      
      context "owned by other user" do
        before{
          expect{ 
            get :rest, {:id => unrelated_channel_account.id, :format => :json}
          }.not_to change{ unrelated_channel_account.reload }
        }
        
        it{ expect(response.code).to eq "403" }
      end
    end
    
    context "logged out" do
      before{
        expect{ 
          get :rest, {:id => channel_account.id, :format => :json}
        }.not_to change{ channel_account.reload }
      }
      
      it{ expect(response.code).to eq "403" }
    end
  end
  
  describe "GET #donate_blood" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        context "inactive" do
          before{
            expect{
              get :donate_blood, {:id => channel_account_inactive.id, :format => :json}
            }.to change{ channel_account_inactive.reload.status }.to("donating_blood")
          }
          
          it{ expect(response.code).to eq "200" }
        end
        
        context "donating_blood" do
          before{
            expect{
              get :donate_blood, {:id => channel_account_donating.id, :format => :json}
            }.not_to change{ channel_account_donating.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "resting" do
          before{
            expect{
              get :donate_blood, {:id => channel_account_resting.id, :format => :json}
            }.not_to change{ channel_account_resting.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "betting" do
          before{
            expect{
              get :donate_blood, {:id => channel_account_betting.id, :format => :json}
            }.not_to change{ channel_account_betting.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
      end
      
      context "owned by other user" do
        before{
          expect{
            get :donate_blood, {:id => unrelated_channel_account.id, :format => :json}
          }.not_to change{ unrelated_channel_account.reload }
        }
        
        it{ expect(response.code).to eq "403" }
      end
    end
    
    context "logged out" do
      before{
        expect{
          get :donate_blood, {:id => channel_account.id, :format => :json}
        }.not_to change{ channel_account.reload }
      }
      
      it{ expect(response.code).to eq "403" }
    end
  end
  
  describe "GET #bet" do
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        context "inactive" do
          before{
            expect{
              get :bet, {:id => channel_account_inactive.id, :enemy_id => 1, :amount => 1, :format => :json}
            }.to change{ channel_account_inactive.reload.status }.to("betting")
          }
          
          it{ expect(response.code).to eq "200" }
        end
        
        context "donating_blood" do
          before{
            expect{
              get :bet, {:id => channel_account_donating.id, :enemy_id => 1, :amount => 1, :format => :json}
            }.not_to change{ channel_account_donating.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "resting" do
          before{
            expect{
              get :bet, {:id => channel_account_resting.id, :enemy_id => 1, :amount => 1, :format => :json}
            }.not_to change{ channel_account_resting.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
        
        context "betting" do
          before{
            expect{
              get :bet, {:id => channel_account_betting.id, :enemy_id => 1, :amount => 1, :format => :json}
            }.not_to change{ channel_account_betting.reload }
          }
          
          it{ expect(response.code).to eq "403" }
        end
      end
      
      context "owned by other user" do
        before{
          expect{
            get :bet, {:id => unrelated_channel_account.id, :enemy_id => 1, :amount => 1, :format => :json}
          }.not_to change{ unrelated_channel_account.reload }
        }
        
        it{ expect(response.code).to eq "403" }
      end
    end
    
    context "logged out" do
      before{
        expect{
          get :bet, {:id => channel_account.id, :enemy_id => 1, :amount => 1, :format => :json}
        }.not_to change{ channel_account.reload }
      }
      
      it{ expect(response.code).to eq "403" }
    end
  end
end