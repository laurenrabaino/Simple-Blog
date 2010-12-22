class CreateComments < ActiveRecord::Migration
  def self.up
    create_table "comments", :force => true do |t|
      t.string   "commentable_type"
      t.integer  "commentable_id"
      t.integer  "user_id"
      t.string   "full_name"
      t.string   "email"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "spam",             :default => false
      t.float    "spaminess"
      t.string   "signature"
      t.string   "ip"
      t.integer  "parent_id"
      t.integer  "level",            :default => 0
    end
  end

  def self.down
    drop_table :comments
  end
end
