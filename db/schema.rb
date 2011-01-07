# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110107162351) do

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

  create_table "blocked_ips", :force => true do |t|
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "seo_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.string   "description"
  end

  create_table "categories_posts", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "category_id"
  end

  create_table "clickstreams", :force => true do |t|
    t.string   "ip"
    t.string   "user_agent"
    t.string   "url"
    t.string   "referer"
    t.string   "session_id"
    t.integer  "user_id"
    t.string   "clickstreamable_type"
    t.integer  "clickstreamable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",               :default => 0
  end

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

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "facebook_accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "fb_user_id"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
  end

  create_table "favorites", :force => true do |t|
    t.string   "ip"
    t.integer  "user_id"
    t.string   "favoriteable_type"
    t.integer  "favoriteable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", :force => true do |t|
    t.string   "ip"
    t.integer  "user_id"
    t.string   "featurable_type"
    t.integer  "featurable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notify_settings", :force => true do |t|
    t.integer  "user_id"
    t.string   "notify_type"
    t.boolean  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "excerpt"
    t.text     "body"
    t.text     "embed_code"
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
    t.integer  "user_id"
    t.boolean  "is_home_page",                             :default => false
  end

  add_index "pages", ["is_home_page"], :name => "index_pages_on_is_home_page"

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
    t.datetime "featured_at"
    t.boolean  "is_home_page",                             :default => false
  end

  add_index "posts", ["is_home_page"], :name => "index_posts_on_is_home_page"

  create_table "settings", :force => true do |t|
    t.integer  "user_id"
    t.string   "full_name"
    t.text     "about_me"
    t.boolean  "is_public",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shared_posts", :force => true do |t|
    t.integer  "user_id"
    t.string   "share_type"
    t.string   "shareable_type"
    t.integer  "shareable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "twitter_accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
  end

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
