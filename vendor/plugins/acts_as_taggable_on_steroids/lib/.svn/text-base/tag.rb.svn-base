class Tag < ActiveRecord::Base
  has_many :taggings
  
  validates_presence_of :name
  #validates_uniqueness_of :name, :case_sensitive => true
  
  cattr_accessor :destroy_unused
  self.destroy_unused = false
  
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE BINARY ?", name]) || create(:name => name)
  end
  
  def self.tags(options = {})
  	query  = "select tags.id, name, taggings.taggable_id, user_id, count(*) as count"
  	query << " from taggings"
  	query << " LEFT JOIN tags ON taggings.tag_id = tags.id"
  	query << " LEFT JOIN user_updates ON taggings.taggable_id = user_updates.contrib_id"
  	query << " where user_id = #{options[:user_id]}" if !options[:user_id].blank?
  	query << (options[:user_id].blank? ? " where taggings.taggable_type='Event'" : " and taggings.taggable_type='Event'")
	query << " and user_updates.update_type='Event'"
  	query << " group by tag_id"
  	query << " order by #{options[:order]}" if options[:order] != nil
  	query << " limit #{options[:limit]}" if options[:limit] != nil
	
	  tags = Tag.find_by_sql(query)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
end
