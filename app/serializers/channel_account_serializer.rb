class ChannelAccountSerializer < ActiveModel::Serializer
  attributes :balance
  
  def attributes
    data[:bets] = object.bets.active
  end
end