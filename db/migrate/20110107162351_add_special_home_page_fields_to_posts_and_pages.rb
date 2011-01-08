class AddSpecialHomePageFieldsToPostsAndPages < ActiveRecord::Migration
  def self.up
    add_column :posts, :is_home_page, :boolean, :default => false
    add_column :pages, :is_home_page, :boolean, :default => false
    add_index :posts, :is_home_page
    add_index :pages, :is_home_page
  end

  def self.down
    remove_column :posts, :is_home_page
    remove_column :pages, :is_home_page
  end
end
