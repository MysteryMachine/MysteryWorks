require 'rails_helper'

describe User do
  let(:user){ create :user }
  
  describe "validations" do
    let!(:other_user){ create :user, :channel => channel_used }
    let!(:channel_used){ create :channel }
    let!(:channel_unused){ create :channel }
    it{ expect(User.new(:channel_id => channel_used.id, :name => "my name").save).to eq(false) }
    it{ expect(User.new(:channel_id => channel_unused.id).save).to eq(false) }
    it{ expect(User.new(:channel_id => channel_unused.id, :name => "my name").save).to eq(true) }
  end
  
  describe "#request_channel" do
    it{ expect(user.request_channel).to eq(true) }
    it{ user.request_channel; expect(user.request_channel).to eq(false) }
    it{ expect{ user.request_channel }.to change{ user.channel }.from(nil) }
    it{ user.request_channel; expect{ user.request_channel }.not_to change{ user.channel } }
  end
  
  describe "#channel_account_for" do
    let(:channel){ create :channel }
    it{ expect{ user.channel_account_for(channel) }.to change{ user.channel_accounts.length }.by(1) }
    it{ user.channel_account_for(channel); expect(user.channel_accounts.last.channel_id).to eq(channel.id) }
  end
  
  describe "permissions helpers" do
    let(:channel_inactive){ create :channel, :status => "inactive", :user => user }
    let(:channel_betting_open){ create :channel, :status => "betting_open", :user => user }
    let(:channel_betting_closed){ create :channel, :status => "betting_closed", :user => user }
    let(:channel_account_inactive){ create :channel_account, :status => "inactive", :user => user }
    let(:channel_account_donating){ create :channel_account, :status => "donating_blood", :user => user }
    let(:channel_account_resting){ create :channel_account, :status => "resting", :user => user }
    let(:channel_account_betting){ create :channel_account, :status => "betting", :user => user }
    let(:unowned_channel_inactive){ create :channel, :status => "inactive" }
    let(:unowned_channel_betting_open){ create :channel, :status => "betting_open" }
    let(:unowned_channel_betting_closed){ create :channel, :status => "betting_closed" }
    let(:unowned_channel_account_inactive){ create :channel_account, :status => "inactive" }
    let(:unowned_channel_account_donating){ create :channel_account, :status => "donating_blood" }
    let(:unowned_channel_account_resting){ create :channel_account, :status => "resting" }
    let(:unowned_channel_account_betting){ create :channel_account, :status => "betting" }
    
    describe "#can_rest" do
      it{ expect(user.can_rest?(channel_account_inactive)).to eq(true) }
      it{ expect(user.can_rest?(channel_account_donating)).to eq(false) }
      it{ expect(user.can_rest?(channel_account_resting)).to eq(false) }
      it{ expect(user.can_rest?(channel_account_betting)).to eq(false) }
      
      it{ expect(user.can_rest?(unowned_channel_account_inactive)).to eq(false) }
      it{ expect(user.can_rest?(unowned_channel_account_donating)).to eq(false) }
      it{ expect(user.can_rest?(unowned_channel_account_resting)).to eq(false) }
      it{ expect(user.can_rest?(unowned_channel_account_betting)).to eq(false) }
    end
    
    describe "#can_donate_blood" do
      it{ expect(user.can_donate_blood?(channel_account_inactive)).to eq(true) }
      it{ expect(user.can_donate_blood?(channel_account_donating)).to eq(false) }
      it{ expect(user.can_donate_blood?(channel_account_resting)).to eq(false) }
      it{ expect(user.can_donate_blood?(channel_account_betting)).to eq(false) }
                          
      it{ expect(user.can_donate_blood?(unowned_channel_account_inactive)).to eq(false) }
      it{ expect(user.can_donate_blood?(unowned_channel_account_donating)).to eq(false) }
      it{ expect(user.can_donate_blood?(unowned_channel_account_resting)).to eq(false) }
      it{ expect(user.can_donate_blood?(unowned_channel_account_betting)).to eq(false) }
    end
    
    describe "#can_bet" do
      it{ expect(user.can_bet?(channel_account_inactive)).to eq(true) }
      it{ expect(user.can_bet?(channel_account_donating)).to eq(false) }
      it{ expect(user.can_bet?(channel_account_resting)).to eq(false) }
      it{ expect(user.can_bet?(channel_account_betting)).to eq(false) }
      
      it{ expect(user.can_bet?(unowned_channel_account_inactive)).to eq(false) }
      it{ expect(user.can_bet?(unowned_channel_account_donating)).to eq(false) }
      it{ expect(user.can_bet?(unowned_channel_account_resting)).to eq(false) }
      it{ expect(user.can_bet?(unowned_channel_account_betting)).to eq(false) }
    end
    
    describe "#can_set_inactive" do
      it{ expect(user.can_set_inactive?(channel_inactive)).to eq(true) }
      it{ expect(user.can_set_inactive?(channel_betting_open)).to eq(true) }
      it{ expect(user.can_set_inactive?(channel_betting_closed)).to eq(true) }

      it{ expect(user.can_set_inactive?(unowned_channel_inactive)).to eq(false) }
      it{ expect(user.can_set_inactive?(unowned_channel_betting_open)).to eq(false) }
      it{ expect(user.can_set_inactive?(unowned_channel_betting_closed)).to eq(false) }
    end
    
    describe "#can_open_betting" do
      it{ expect(user.can_open_betting?(channel_inactive)).to eq(true) }
      it{ expect(user.can_open_betting?(channel_betting_open)).to eq(false) }
      it{ expect(user.can_open_betting?(channel_betting_closed)).to eq(false) }

      it{ expect(user.can_open_betting?(unowned_channel_inactive)).to eq(false) }
      it{ expect(user.can_open_betting?(unowned_channel_betting_open)).to eq(false) }
      it{ expect(user.can_open_betting?(unowned_channel_betting_closed)).to eq(false) }
    end
    
    describe "#can_close_betting" do
      it{ expect(user.can_close_betting?(channel_inactive)).to eq(false) }
      it{ expect(user.can_close_betting?(channel_betting_open)).to eq(true) }
      it{ expect(user.can_close_betting?(channel_betting_closed)).to eq(false) }

      it{ expect(user.can_close_betting?(unowned_channel_inactive)).to eq(false) }
      it{ expect(user.can_close_betting?(unowned_channel_betting_open)).to eq(false) }
      it{ expect(user.can_close_betting?(unowned_channel_betting_closed)).to eq(false) }
    end
    
    describe "#can_complete_betting" do
      it{ expect(user.can_complete_betting?(channel_inactive)).to eq(false) }
      it{ expect(user.can_complete_betting?(channel_betting_open)).to eq(false) }
      it{ expect(user.can_complete_betting?(channel_betting_closed)).to eq(true) }

      it{ expect(user.can_complete_betting?(unowned_channel_inactive)).to eq(false) }
      it{ expect(user.can_complete_betting?(unowned_channel_betting_open)).to eq(false) }
      it{ expect(user.can_complete_betting?(unowned_channel_betting_closed)).to eq(false) }
    end
  end
end