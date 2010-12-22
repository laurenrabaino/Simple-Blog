class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table "settings", :force => true do |t|
      t.integer  "user_id"
      t.string   "full_name"
      t.text     "about_me"
      t.boolean  "is_public", :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :settings
  end
end
