class ChannelSerializer < ActiveModel::Serializer
  attributes :name, :status, :pot
  
  def attributes
    data = super
    if !scope.nil?
      data[:channel_account] = object.find_or_create_users_channel_account(scope)
    end
    data
  end
end