class ChannelSerializer < ActiveModel::Serializer
  attributes :id, :name, :status, :pot
  
  def attributes
    data = super
    if !scope.nil?
      data[:channel_account] = ChannelAccountSerializer.new(object.find_or_create_users_channel_account(scope)).as_json(:root => false)
    end
    data
  end
end