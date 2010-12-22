class CreateSharedPosts < ActiveRecord::Migration
  def self.up
    create_table "shared_posts", :force => true do |t|
      t.integer  "user_id"
      t.string   "share_type"
      t.string   "shareable_type"
      t.integer  "shareable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :shared_posts
  end
end
