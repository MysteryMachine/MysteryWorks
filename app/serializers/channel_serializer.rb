class ChannelSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :name, :status, :whole_pot
  
  def attributes
    data = super
    if !scope.nil?
      data[:channel_account] = ChannelAccountSerializer.new(object.find_channel_account(scope)).as_json(:root => false)
    end
    data
  end
end