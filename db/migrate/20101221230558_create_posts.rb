class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table "posts", :force => true do |t|
      t.string   "title"
      t.text     "excerpt"
      t.text     "body"
      t.text     "embed_code"
      t.string   "keywords"
      t.boolean  "tweeted"
      t.boolean  "facebooked"
      t.integer  "status",                      :limit => 2, :default => 0
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "featured_image_file_name"
      t.string   "featured_image_content_type"
      t.integer  "featured_image_file_size"
      t.datetime "featured_image_updated_at"
      t.string   "featured_image_caption"
      t.integer  "favorited",                                :default => 0
      t.integer  "viewed",                                   :default => 0
      t.boolean  "allow_comments",                           :default => true
      t.boolean  "delta",                                    :default => true,  :null => false
      t.boolean  "featured",                                 :default => false
    end
  end

  def self.down
    drop_table :posts
  end
end
