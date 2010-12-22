class CreatePages < ActiveRecord::Migration
  def self.up
    create_table "pages", :force => true do |t|
      t.string   "title"
      t.text     "excerpt"
      t.text     "body"
      t.text     "embed_code"
      t.integer  "category_id"
      t.integer  "status",                      :limit => 2, :default => 1
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "allow_comments",                           :default => true
      t.string   "cached_tag_list"
      t.boolean  "top_menu",                                 :default => true
      t.string   "featured_image_file_name"
      t.string   "featured_image_content_type"
      t.integer  "featured_image_file_size"
      t.datetime "featured_image_updated_at"
      t.string   "featured_image_caption"
      t.integer  "favorited",                                :default => 0
      t.integer  "viewed",                                   :default => 0
      t.boolean  "featured",                                 :default => false
      t.boolean  "delta",                                    :default => true,  :null => false
      t.datetime "featured_at"
    end
  end

  def self.down
    drop_table :pages
  end
end
