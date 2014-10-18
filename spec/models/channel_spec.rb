require 'rails_helper'

describe Channel do
  it "can go through the entire model side flow" do
    channel = Channel.new(:name => "Mantron", :user => create(:user))
    channel.save!
    
    account_1 = ChannelAccount.new(:channel => channel, :user => create(:user))
    account_2 = ChannelAccount.new(:channel => channel, :user => create(:user))
    account_3 = ChannelAccount.new(:channel => channel, :user => create(:user), :health => 5)
    account_4 = ChannelAccount.new(:channel => channel, :user => create(:user))
    
    account_1.save!
    account_2.save!
    account_3.save!
    account_4.save!
    
    channel.open_betting
    
    account_1.bet(5, 1)
    account_2.bet(5, 2)
    account_3.rest
    account_4.donate_blood
    
    channel.close_betting
    
    channel.complete_betting(1)
    
    expect(account_1.reload.balance).to eq(15)
    expect(account_2.reload.balance).to eq(5)
    expect(account_3.reload.balance).to eq(10)
    expect(account_4.reload.balance > 10).to eq(true)
    
    expect(account_1.health).to eq(6)
    expect(account_2.health).to eq(6)
    expect(account_3.health).to eq(6)
    expect(account_4.health).to eq(5)
    
    account_4.health = 6
    account_3.health = 5
    account_4.save!
    account_3.save!
    
    balance = account_4.balance
    
    channel.open_betting
    
    account_1.reload.bet(5, 2)
    account_2.reload.bet(5, 2)
    account_3.reload.rest
    account_4.reload.donate_blood
    
    channel.complete_betting(1)
    
    expect(account_1.reload.balance).to eq(15)
    expect(account_2.reload.balance).to eq(5)
    expect(account_3.reload.balance).to eq(10)
    expect(account_4.reload.balance > balance).to eq(true)
    
    expect(account_1.health).to eq(6)
    expect(account_2.health).to eq(6)
    expect(account_3.health).to eq(6)
    expect(account_4.health).to eq(5)
  end
  
  describe "permission helpers" do
    let(:channel_inactive){ create :channel, :status => "inactive" }
    let(:channel_betting_open){ create :channel, :status => "betting_open" }
    let(:channel_betting_closed){ create :channel, :status => "betting_closed" }
    
    describe "#can_set_inactive" do
      it{ expect(channel_inactive.can_set_inactive?).to eq(true) }
      it{ expect(channel_betting_open.can_set_inactive?).to eq(true) }
      it{ expect(channel_betting_closed.can_set_inactive?).to eq(true) }
    end
    
    describe "#can_open_betting" do
      it{ expect(channel_inactive.can_open_betting?).to eq(true) }
      it{ expect(channel_betting_open.can_open_betting?).to eq(false) }
      it{ expect(channel_betting_closed.can_open_betting?).to eq(false) }
    end
    
    describe "#can_close_betting" do
      it{ expect(channel_inactive.can_close_betting?).to eq(false) }
      it{ expect(channel_betting_open.can_close_betting?).to eq(true) }
      it{ expect(channel_betting_closed.can_close_betting?).to eq(false) }
    end
    
    describe "#can_complete_betting" do
      it{ expect(channel_inactive.can_complete_betting?).to eq(false) }
      it{ expect(channel_betting_open.can_complete_betting?).to eq(false) }
      it{ expect(channel_betting_closed.can_complete_betting?).to eq(true) }
    end
  end
  
  describe "#set_inactive" do
    let!(:channel){ create :channel, :with_bets, :status => "betting_open" }
    
    it{ expect{ channel.set_inactive }.to change{ channel.channel_accounts.first.balance }.by(10) }
    it{ expect{ channel.set_inactive }.to change{ channel.bets.first.status }.from("open").to("invalidated") }
    it{ expect{ channel.set_inactive }.to change{ channel.status }.from("betting_open").to("inactive") }
    
    it{ expect{ channel.set_inactive }.not_to change{ channel.channel_accounts[1] } }
    it{ expect{ channel.set_inactive }.not_to change{ channel.channel_accounts[2] } }
    it{ expect{ channel.set_inactive }.not_to change{ channel.channel_accounts[3] } }
    it{ expect{ channel.set_inactive }.not_to change{ channel.channel_accounts[4] } }
    
    describe "is transactional" do
      context "invalidate bets fails" do
        before{
          channel.stub(:invalidate_bets){ Bet.new.save! }
        } 
        it{ expect{ channel.set_inactive }.not_to change{ channel } }  
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[0] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[1] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[2] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[3] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[4] } }
      end
      context "save bets fails" do
        before{
          channel.stub(:save!){ Bet.new.save! }
        } 
        it{ expect{ channel.set_inactive }.not_to change{ channel } }  
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[0] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[1] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[2] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[3] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[4] } }
      end
    end
  end
  
  describe "#open_betting" do
    let(:channel){ create :channel, :status => "betting_closed" }
    
    it{ expect{ channel.open_betting }.to change{ channel.status }.from("betting_closed").to("betting_open") } 
  end
  
  describe "#close_betting" do
    let(:channel){ create :channel, :status => "betting_open" }
    
    it{ expect{ channel.close_betting }.to change{ channel.status }.from("betting_open").to("betting_closed") }
  end
  
  describe "#pot" do
    let!(:channel){ create :channel, :with_bets, :status => "betting_closed" }
    
    it{ expect(channel.pot).to eq(20) }
  end
  
  describe "#active_bets" do
    let!(:channel){ create :channel, :with_bets, :status => "betting_closed" }
    
    it{ expect(channel.active_bets).to match([channel.bets[0], channel.bets[1]]) }
  end
  
  describe "#complete_bets" do
    let!(:channel){ create :channel, :with_bets, :status => "betting_closed" }
    let!(:channel_account_right){ channel.channel_accounts[0] }
    let!(:channel_account_wrong){ channel.channel_accounts[1] }
    let!(:channel_account_closed){ channel.channel_accounts[2] }
    let!(:channel_account_invalidated){ channel.channel_accounts[3] }
    let!(:channel_account_paid){ channel.channel_accounts[4] }
    let!(:channel_account_resting){ channel.channel_accounts[5] }
    let!(:channel_account_donating){ channel.channel_accounts[6] }
    
    it{ expect{ channel.complete_betting(1) }.to change{ channel_account_right.reload.status }.to("inactive") }
    it{ expect{ channel.complete_betting(1) }.to change{ channel_account_wrong.reload.status }.to("inactive") }
    it{ expect{ channel.complete_betting(1) }.to change{ channel_account_resting.reload.status }.to("inactive") }
    it{ expect{ channel.complete_betting(1) }.to change{ channel_account_donating.reload.status }.to("inactive") }
    
    it{ expect{ channel.complete_betting(1) }.to change{ channel_account_right.reload.balance }.by(20) }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_wrong.reload.balance } }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_closed.reload.balance } }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_invalidated.reload.balance } }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_paid.reload.balance } }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_resting.reload.balance } }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_donating.reload.balance } }
    
    it{ expect{ channel.complete_betting(1) }.to change{ channel_account_right.reload.bets[0].status }.from("open").to("paid_out") }
    it{ expect{ channel.complete_betting(1) }.to change{ channel_account_wrong.reload.bets[0].status }.from("open").to("closed") }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_closed.reload.bets[0].status }.from("closed") }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_invalidated.reload.bets[0].status }.from("invalidated") }
    it{ expect{ channel.complete_betting(1) }.not_to change{ channel_account_paid.reload.bets[0].status }.from("paid_out") }
    
    it{ expect{ channel.complete_betting(1) }.to change{ channel.status }.from("betting_closed").to("inactive") }
    
    describe "is transactional" do
      context "pay_out bets fails" do
        before{
          channel.stub(:pay_out){ Bet.new.save! }
        } 
        it{ expect{ channel.set_inactive }.not_to change{ channel } }  
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[0] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[1] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[2] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[3] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[4] } }
      end
      context "save bets fails" do
        before{
          channel.stub(:deactivate){ Bet.new.save! }
        } 
        it{ expect{ channel.set_inactive }.not_to change{ channel } }  
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[0] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[1] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[2] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[3] } }
        it{ expect{ channel.set_inactive }.not_to change{ channel.bets[4] } }
      end
    end
  end
end