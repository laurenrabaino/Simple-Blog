class CreateTwitterAccounts < ActiveRecord::Migration
  def self.up
    create_table "twitter_accounts", :force => true do |t|
      t.integer  "user_id"
      t.string   "token"
      t.string   "secret"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "site_id"
    end
  end

  def self.down
    drop_table :twitter_accounts
  end
end
