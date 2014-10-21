class ChannelAccountSerializer < ActiveModel::Serializer
  attributes :balance
  
  def attributes
    data = super
    data[:bets] = object.bets.active
    data
  end
end