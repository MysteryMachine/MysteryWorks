class AddFancyNameToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :fancy_name, :string, :null => false
  end
end
