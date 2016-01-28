class AddSharesToLinks < ActiveRecord::Migration
  def change
    add_column :links, :share, :text
  end
end
