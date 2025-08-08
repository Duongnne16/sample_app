class DropMicropostsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :microposts, if_exists: true
  end
end
