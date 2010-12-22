class CreateBlockedIps < ActiveRecord::Migration
  def self.up
    create_table "blocked_ips", :force => true do |t|
      t.string   "ip"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :blocked_ips
  end
end
