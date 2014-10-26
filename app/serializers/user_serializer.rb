class UserSerializer < ActiveModel::Serializer
  attributes :channel_id, :name, :display_name
end