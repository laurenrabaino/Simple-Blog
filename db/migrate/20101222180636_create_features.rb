class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table "features", :force => true do |t|
      t.string   "ip"
      t.integer  "user_id"
      t.string   "featurable_type"
      t.integer  "featurable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :features
  end
end
