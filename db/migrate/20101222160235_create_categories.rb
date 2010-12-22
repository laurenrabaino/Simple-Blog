class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table "categories", :force => true do |t|
      t.string   "name"
      t.string   "seo_name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id"
      t.string   "description"
    end
    remove_column :pages, :category_id
  end

  def self.down
    drop_table :categories
    add_column :pages, :category_id, :integer
  end
end
