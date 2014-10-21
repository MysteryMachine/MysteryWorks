class ChannelAccountSerializer < ActiveModel::Serializer
  attributes :id, :balance, :health, :max_health, :status, :user_id
  
  def attributes
    data = super
    data[:bets] = object.bets.active.map {|obj| BetSerializer.new(obj).as_json(:root => false)}
    data
  end
end