require 'rails_helper'

describe ChannelsController do
  let(:user){ create :user }
  let(:json){ JSON.parse response.body }
  let(:channel_inactive){ create :channel, :status => "inactive", :user => user }
  let(:channel_betting_open){ create :channel, :status => "betting_open", :user => user }
  let(:channel_betting_closed){ create :channel, :status => "betting_closed", :user => user }
  let(:channel){ create :channel, :user => user }
  let(:unrelated_channel){ create :channel }
  
  describe "POST #create" do
    context "logged in" do
      before{
        sign_in user
      }
      
      context "first time" do
        before{
          post :create
        }
        it{ expect(response.code).to eq "200" }
        it{ expect(user.reload.channel).not_to eq(nil) }
        it{ expect(json["id"]).to eq(user.reload.channel.id) }
      end
      
      context "other time or failures" do
        let(:channel_id){ user.channel.id }
        before{
          post :create
        }
        it{ post :create; expect(response.code).to eq("400") }
        it{ expect{ post :create }.not_to change{ user.reload.channel } }
      end
    end
    
    context "logged out" do
      before{
        post :create
      }
      it{ expect(response.code).to eq "403" }
    end
  end
  
  describe "GET #show" do
    let(:channel_account){ channel.channel_accounts.first }
    
    context "account creation" do
      let(:new_user){ create :user }
      before{
        sign_in new_user
        expect(new_user.channel_accounts.length).to eq(0)
        channel.status = "betting_open"
        channel.save!
        get :show, {:name => channel.name, :format => :json}
      }
      
      it{ expect(response.code).to eq "200" }
      it{ expect(new_user.reload.channel_accounts.length).to eq(1) }
      it{ expect(new_user.reload.channel_accounts.first.channel_id).to eq(channel.id) }
      it{
        get :show, {:name => channel.name, :format => :json}; expect(new_user.reload.channel_accounts.length).to eq(1)
      }
    end
    
    context "user" do
      before{
        sign_in user
      }
      
      context "owned by user" do
        before{
          channel.status = "betting_open"
          channel.save!
          get :show, {:name => channel.name, :format => :json}
        }
        
        it{ expect(response.code).to eq "200" }
        it{ 
          expect(json).to eq({ "id" => channel.id,
            "name" => channel.name,
            "display_name" => channel.display_name,
            "status" => channel.status,
            "whole_pot" => channel.whole_pot,
            "channel_account" => { "id" => channel_account.id,
              "balance" => channel_account.balance,
              "health" => channel_account.health,
              "max_health" => channel_account.max_health,
              "status" => channel_account.status,
              "user_id" => user.id,
              "bets" => []
            }
          })
        }
        
        context "in the middle of betting" do
          before{
            channel_account.bet(5, 5)
            get :show, {:name => channel.name, :format => :json}
          }
          
          it{ 
            expect(json).to eq({ "id" => channel.id,
              "name" => channel.name,
              "display_name" => channel.display_name,
              "status" => channel.status,
              "whole_pot" => 5,
              "channel_account" => { "id" => channel_account.id,
                "balance" => 5,
                "health" => channel_account.health,
                "max_health" => channel_account.max_health,
                "status" => channel_account.status,
                "user_id" => user.id,
                "bets" => [{
                  "amount" => 5,
                  "enemy_id" => 5
                }]
              }
            })
          }
        end
      end
      
      context "owned by other user" do
        let!(:user){ create :user, :channel => unrelated_channel }
        before{
          get :show, {:name => unrelated_channel.name, :format => :json}
        }
        
        it{ expect(response.code).to eq "200" }
        it{ 
          expect(json).to eq({ "id" => unrelated_channel.id,
            "name" => unrelated_channel.name,
            "display_name" => unrelated_channel.display_name,
            "status" => unrelated_channel.status,
            "whole_pot" => unrelated_channel.whole_pot,
            "channel_account" => { "id" => unrelated_channel.channel_accounts.first.id,
              "health" => unrelated_channel.channel_accounts.first.health,
              "max_health" => unrelated_channel.channel_accounts.first.max_health,
              "balance" => unrelated_channel.channel_accounts.first.balance,
              "status" => unrelated_channel.channel_accounts.first.status,
              "bets" => [],
              "user_id" => user.id
            }
          })
        }
      end
    end
    
    context "logged out" do
      before{
        get :show, {:name => channel.name, :format => :json}
      }
      
      it{ expect(response.code).to eq "200" }
      it{ 
        expect(json).to eq({ "id" => channel.id,
          "name" => channel.name,
          "display_name" => channel.display_name,
          "status" => channel.status,
          "whole_pot" => channel.whole_pot,
        })
     }
    end
    
    context "non-existant channel" do
      context "user" do
        before{
          sign_in create(:user)
          get :show, {:name => "this is not a channel", :format => :json}
        }
      
        it{ expect(response.code).to eq "400" }
      end
      
      context "logged out" do
        before{
          get :show, {:name => "this is not a channel", :format => :json}
        }
      
        it{ expect(response.code).to eq "400" }
      end
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
          it{ expect(channel_inactive.reload.status).to eq("inactive") }
        end
        
        context "betting_open" do
          before{
            get :set_inactive, {:id => channel_betting_open.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
          it{ expect(channel_betting_open.reload.status).to eq("inactive") }
        end
        
        context "betting_closed" do
          before{
            get :set_inactive, {:id => channel_betting_closed.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
          it{ expect(channel_betting_closed.reload.status).to eq("inactive") }
        end
      end
      
      context "owned by other user" do
        before{
          unrelated_channel.status = "betting_open"
          expect(unrelated_channel.save).to eq(true)
          get :set_inactive, {:id => unrelated_channel.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "403" }
        it{ expect(unrelated_channel.reload.status).not_to eq("inactive") }
      end
    end
    
    context "logged out" do
      before{
        channel.status = "betting_open"
        expect(channel.save).to eq(true)
        get :set_inactive, {:id => channel.id, :format => :json}
      }
      
      it{ expect(response.code).to eq "403" }
      it{ expect(channel.reload.status).not_to eq("inactive") }
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
          it{ expect(channel_inactive.reload.status).to eq("betting_open") }
        end
        
        context "betting_open" do
          before{
            get :open_betting, {:id => channel_betting_open.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
          it{ expect(channel_betting_open.reload.status).to eq("betting_open") }
        end
        
        context "betting_closed" do
          before{
            get :open_betting, {:id => channel_betting_closed.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
          it{ expect(channel_betting_closed.reload.status).not_to eq("betting_open") }
        end
      end
      
      context "owned by other user" do
        before{
          get :open_betting, {:id => unrelated_channel.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "403" }
        it{ expect(unrelated_channel.reload.status).not_to eq("betting_open") }
      end
    end
    
    context "logged out" do
      before{
        get :open_betting, {:id => channel.id, :format => :json}
      }
      
      it{ expect(response.code).to eq "403" }
      it{ expect(channel.reload.status).not_to eq("betting_open") }
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
          it{ expect(channel_inactive.reload.status).not_to eq("betting_closed") }
        end
        
        context "betting_open" do
          before{
            get :close_betting, {:id => channel_betting_open.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
          it{ expect(channel_betting_open.reload.status).to eq("betting_closed") }
        end
        
        context "betting_closed" do
          before{
            get :close_betting, {:id => channel_betting_closed.id, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
          it{ expect(channel_betting_closed.reload.status).to eq("betting_closed") }
        end
      end
      
      context "owned by other user" do
        before{
          get :close_betting, {:id => unrelated_channel.id, :format => :json}
        }
        
        it{ expect(response.code).to eq "403" }
        it{ expect(unrelated_channel.reload.status).not_to eq("betting_closed") }
      end
    end
    
    context "logged out" do
      before{
        get :close_betting, {:id => channel.id, :format => :json}
      }
      
      it{ expect(response.code).to eq "403" }
      it{ expect(channel.reload.status).not_to eq("betting_closed") }
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
          it{ expect(channel_inactive.reload.status).not_to eq("betting_closed") }
        end
        
        context "betting_open" do
          before{
            get :complete_betting, {:id => channel_betting_open.id, :enemy_id => 1, :format => :json}
          }
          
          it{ expect(response.code).to eq "403" }
          it{ expect(channel_betting_open.reload.status).not_to eq("betting_closed") }
        end
        
        context "betting_closed" do
          before{
            get :complete_betting, {:id => channel_betting_closed.id, :enemy_id => 1, :format => :json}
          }
          
          it{ expect(response.code).to eq "200" }
          it{ expect(channel_betting_closed.reload.status).not_to eq("betting_closed") }
        end
      end
      
      context "owned by other user" do
        before{
          unrelated_channel.status = "betting_open"
          expect(unrelated_channel.save).to eq(true)
          get :complete_betting, {:id => unrelated_channel.id, :enemy_id => 1, :format => :json}
        }
        
        it{ expect(response.code).to eq "403" }
        it{ expect(unrelated_channel.reload.status).not_to eq("betting_closed") }
      end
    end
    
    context "logged out" do
      before{
        channel.status = "betting_open"
        expect(channel.save).to eq(true)
        get :complete_betting, {:id => channel.id, :enemy_id => 1, :format => :json}
      }
      
      it{ expect(response.code).to eq "403" }
      it{ expect(channel.reload.status).not_to eq("inactive") }
    end
  end
end