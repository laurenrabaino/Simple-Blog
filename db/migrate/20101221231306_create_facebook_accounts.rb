class CreateFacebookAccounts < ActiveRecord::Migration
  def self.up
    create_table "facebook_accounts", :force => true do |t|
      t.integer  "user_id"
      t.string   "fb_user_id"
      t.string   "code"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "site_id"
    end
  end

  def self.down
    drop_table :facebook_accounts
  end
end
