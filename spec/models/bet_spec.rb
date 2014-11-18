require 'rails_helper'

describe Bet do
  let(:bet){ create :bet }
  before{
    Bet.all.each {|b| b.destroy}
  }
  
  describe "#pay_out" do
    it{ expect{ bet.pay_out(10, 20) }.to change { bet.channel_account.balance }.by(20) }
    it{ expect{ bet.pay_out(15, 20) }.to change { bet.channel_account.balance }.by(14) }
    it{ expect{ bet.pay_out(10, 10) }.to change { bet.channel_account.balance }.by(10) }
    it{ expect{ bet.pay_out(10, 20) }.to change { bet.status }.from("open").to("paid_out") }
  end
  
  describe "#close" do
    it{ expect{ bet.close }.to change{ bet.status }.from("open").to("closed") }
  end
  
  describe "#invalidate" do
    it{ expect{ bet.invalidate }.to change{ bet.status }.from("open").to("invalidated") }
  end
  
  describe "scopes" do
    let(:losing_bet){ create :bet, :loser }
    let(:inactive_bet_1){ create :bet, :closed }
    let(:inactive_bet_2){ create :bet, :paid_out }
    let(:inactive_bet_3){ create :bet, :invalidated }
    before{
      bet
      losing_bet
      inactive_bet_1
      inactive_bet_2
      inactive_bet_3
    }
    
    describe ".active" do
      it{ expect(Bet.active.to_a).to match_array [losing_bet, bet] }
    end
    
    describe ".winners" do
      it{ expect(Bet.winners(1).to_a).to match_array [bet] }
    end
    
    describe ".losers" do
      it{ expect(Bet.losers(1).to_a).to match_array [losing_bet] }
    end
  end
end
