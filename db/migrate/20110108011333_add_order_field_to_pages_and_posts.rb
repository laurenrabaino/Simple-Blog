class AddOrderFieldToPagesAndPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :position, :integer, :default => 100000
    add_column :pages, :position, :integer, :default => 100000
    add_index :posts, :position
    add_index :pages, :position
  end

  def self.down
    remove_column :posts, :position
    remove_column :pages, :position
  end
end
