class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string   "user_name"
      t.string   "password"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "email"
      t.string   "activation_code"
      t.boolean  "is_admin",                :default => false
      t.boolean  "terms_of_service"
      t.string   "avatar_file_name"
      t.string   "avatar_content_type"
      t.integer  "avatar_file_size"
      t.datetime "avatar_updated_at"
      t.integer  "favorited",               :default => 0
      t.integer  "viewed",                  :default => 0
      t.integer  "featured",                :default => 0
      t.integer  "status",                  :default => 2
      t.string   "temporary_password"
      t.string   "temporary_password_hash"
      t.datetime "featured_at"
    end
  end

  def self.down
    drop_table :users
  end
end
