require 'rails_helper'

describe ChannelAccount do
  let(:channel_account){ create :channel_account }
  
  describe "#health_correct" do
    it{ 
      channel_account.health_correct
      expect(channel_account.errors.messages[:health].nil?).to eq(true)
    }
    it{ 
      channel_account.health = 100
      channel_account.health_correct
      expect(channel_account.errors.messages[:health].first).to eq("too much health")
    }
  end
  
  describe "#pay_out" do
    it{ expect{ channel_account.pay_out(10).to change{channel_account.balance}.by(10) } }
  end
  
  describe "#deactivate" do
    before{
      channel_account.status = "testing"
    }
    it{ expect{ channel_account.deactivate }.to change{ channel_account.status }.to("inactive") }
  end
  
  describe "#rest" do
    let(:intitial_health){ channel_account.health }
    context "correct usage" do
      before{
        channel_account.health = 5
      }
      it { expect{ channel_account.rest }.to change{ channel_account.status }.to("resting")}
      
      it{ expect{ channel_account.rest }.to change{ channel_account.health }.to(6) }
    end
  end
  
  describe "#donate_blood" do
    let(:initial_balance){ channel_account.balance }
    it { expect{ channel_account.donate_blood }.to change{ channel_account.status }.to eq("donating_blood") }
    
    it{ expect{ channel_account.donate_blood }.to change{ channel_account.health }.to(5) }
    
    it{ 
      initial_balance
      channel_account.donate_blood

      expect(channel_account).to satisfy { |ca| ca.balance > initial_balance } 
    }
    
  end
  
  describe "#bet" do 
    it{
      channel_account.bet(20, 2)
      expect(channel_account.bets.first.errors.messages[:amount].first).to eq("is not included in the list")
    }

    it{ expect(channel_account.bet(1, 1)).to eq(true) }
    it{ expect{ channel_account.bet(1, 1) }.to change{ channel_account.status }.to("betting") }
    it{ expect(channel_account.bet(-1, 1)).to eq(false) }
    it{ 
      channel_account.bet(-1, 1)
      expect(channel_account.bets.first.errors.messages[:amount].first).to eq("is not included in the list")
    }
    it{ expect{channel_account.bet(1, 1)}.to change{channel_account.bets.length}.by(1) }
    it{
      channel_account.bet(1,1)
      bet = channel_account.bets.last
      expect(bet.amount).to eq(1)
      expect(bet.enemy_id).to eq(1)
      expect(bet.channel_account_id).to eq(channel_account.id)
    }
    
    context "maintains transactionality" do
      before{ 
        channel_account.stub(:save!) { Bet.new.save! }
      }
      it{ expect(channel_account.bet(1,1)).to eq(false)}
      it{ expect{ channel_account.bet(1,1) }.not_to change{ Bet.all } }
      it{ expect{ channel_account.bet(1,1) }.not_to change{ channel_account } }
    end
  end
  
  describe "permissions helpers" do
    let(:channel_account_inactive){ create :channel_account, :status => "inactive" }
    let(:channel_account_donating){ create :channel_account, :status => "donating_blood" }
    let(:channel_account_resting){ create :channel_account, :status => "resting" }
    let(:channel_account_betting){ create :channel_account, :status => "betting" }
    
    describe "#can_rest" do
      it{ expect(channel_account_inactive.can_rest?).to eq(true) }
      it{ expect(channel_account_donating.can_rest?).to eq(false) }
      it{ expect(channel_account_resting.can_rest?).to eq(false) }
      it{ expect(channel_account_betting.can_rest?).to eq(false) }
    end
    
    describe "#can_donate_blood" do
      it{ expect(channel_account_inactive.can_rest?).to eq(true) }
      it{ expect(channel_account_donating.can_rest?).to eq(false) }
      it{ expect(channel_account_resting.can_rest?).to eq(false) }
      it{ expect(channel_account_betting.can_rest?).to eq(false) }
    end
    
    describe "#can_bet" do
      it{ expect(channel_account_inactive.can_rest?).to eq(true) }
      it{ expect(channel_account_donating.can_rest?).to eq(false) }
      it{ expect(channel_account_resting.can_rest?).to eq(false) }
      it{ expect(channel_account_betting.can_rest?).to eq(false) }
    end
  end
  
  describe "validations" do
    it{
      expect(channel_account.valid?).to eq(true)
    }
    
    it{
      channel_account.channel_id = -1
      expect(channel_account.valid?).to eq(false)
    }
    
    it{
      channel_account.channel_id = nil
      expect(channel_account.valid?).to eq(false)
    }
    
    it{
      channel_account.balance = nil
      expect(channel_account.valid?).to eq(false)
    }
    
    it{
      channel_account.balance = -1
      expect(channel_account.valid?).to eq(false)
    }
    
    it{
      channel_account.balance = 0
      expect(channel_account.valid?).to eq(true)
    }
    
    it{
      channel_account.health = 0
      expect(channel_account.valid?).to eq(false)
    }
    
    it{
      channel_account.health = 7
      expect(channel_account.valid?).to eq(false)
    }
    
    it{
      channel_account.health = 1
      expect(channel_account.valid?).to eq(true)
    }
    
    it{
      channel_account.health = 6
      expect(channel_account.valid?).to eq(true)
    }
    
    it{
      channel_account.max_health = 20
      expect(channel_account.valid?).to eq(true)
    }
    
    it{
      channel_account.max_health = 6
      expect(channel_account.valid?).to eq(true)
    }
    
    it{
      channel_account.max_health = 21
      expect(channel_account.valid?).to eq(false)
    }
    
    it{
      channel_account.max_health = 5
      expect(channel_account.valid?).to eq(false)
    }
    
    it{
      channel_account.status = "random"
      expect(channel_account.valid?).to eq(false)
    }
  end
  
  describe "defaults" do
    it{ expect(ChannelAccount.new.health).to eq(6) }
    it{ expect(ChannelAccount.new.max_health).to eq(6) }
    it{ expect(ChannelAccount.new.balance).to eq(10) }
    it{ expect(ChannelAccount.new.status).to eq("inactive")}
  end
end