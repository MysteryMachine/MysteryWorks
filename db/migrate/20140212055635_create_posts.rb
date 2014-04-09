class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :image
      t.text :text
      t.integer :blog_id

      t.timestamps
    end
  end
end
