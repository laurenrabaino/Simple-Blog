class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table "favorites", :force => true do |t|
      t.string   "ip"
      t.integer  "user_id"
      t.string   "favoriteable_type"
      t.integer  "favoriteable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :favorites
  end
end
