require 'rails_helper'

describe Channel do
  describe "#set_inactive" do
    let!(:channel){ create :channel, :with_bets }
    
    it {expect{channel.set_inactive}.to change{channel.bets.first.user.balance}.by(10)}
    it {expect{channel.set_inactive}.to change{channel.bets.first.status}.from("open").to("invalidated")}
    it {expect{channel.set_inactive}.to change{channel.state}.from("betting_open").to("inactive")}
  end
  
  describe "#open_betting" do
    let(:channel){ create :channel, :state => "betting_closed" }
    
    it{expect{channel.open_betting}.to change{channel.state}.from("betting_closed").to("betting_open")}
  end
  
  describe "#close_betting" do
    let(:channel){ create :channel }
    
    it{expect{channel.close_betting}.to change{channel.state}.from("betting_open").to("betting_closed")}
  end
  
  describe "#complete_bets" do
    let!(:channel){ create :channel, :with_bets, :state => "betting_closed" }
    
    it {expect{channel.complete_betting(1)}.to change{channel.bets.first.user.balance}.by(50)}
    it {expect{channel.complete_betting(1)}.to change{channel.bets.second.user.balance}.by(0)}
    it {expect{channel.complete_betting(1)}.to change{channel.bets.first.status}.from("open").to("paid_out")}
    it {expect{channel.complete_betting(1)}.to change{channel.bets.second.status}.from("open").to("closed")}
    it {expect{channel.complete_betting(1)}.to change{channel.state}.from("betting_closed").to("inactive")}
  end
end