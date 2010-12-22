class CreateNotifySettings < ActiveRecord::Migration
  def self.up
    create_table "notify_settings", :force => true do |t|
      t.integer  "user_id"
      t.string   "notify_type"
      t.boolean  "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :notify_settings
  end
end
