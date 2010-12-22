class CreateClickstreams < ActiveRecord::Migration
  def self.up
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
  end

  def self.down
    drop_table :clickstreams
  end
end
