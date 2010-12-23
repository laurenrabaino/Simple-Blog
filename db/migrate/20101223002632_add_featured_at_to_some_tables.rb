class AddFeaturedAtToSomeTables < ActiveRecord::Migration
  def self.up
    add_column :posts, :featured_at, :datetime
  end

  def self.down
    remove_column :posts, :featured_at
  end
end
