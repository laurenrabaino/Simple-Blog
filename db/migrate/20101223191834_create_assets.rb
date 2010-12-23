class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table "assets", :force => true do |t|
      t.string   "data_file_name"
      t.string   "data_content_type"
      t.integer  "data_file_size"
      t.integer  "assetable_id"
      t.string   "assetable_type",    :limit => 25
      t.string   "type",              :limit => 25
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "facebooked"
      t.boolean  "tweeted"
      t.boolean  "featured",                        :default => false
      t.datetime "featured_at"
      t.integer  "favorited",                       :default => 0
      t.integer  "viewed",                          :default => 0
      t.boolean  "allow_comments",                  :default => true
      t.string   "title"
      t.string   "tag_list"
      t.text     "body"
      t.text     "excerpt"
    end
  end

  def self.down
    drop_table :assets
  end
end
