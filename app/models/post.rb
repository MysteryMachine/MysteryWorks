class Post < ActiveRecord::Base
  attr_accessible :blog_id, :image, :text, :title
  belongs_to :blog
end
