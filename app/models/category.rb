class Category < ActiveRecord::Base
  
  extend ActiveSupport::Memoizable
  include ActiveSupport::Memoizable

  has_and_belongs_to_many :posts

  before_save :correct_params

  validates_presence_of :name, :on => :create, :message => I18n.t('errors.category.name')

  has_many :categories, :foreign_key => :parent_id, :class_name => "Category"

  def correct_params
    self.seo_name = self.name.to_param.downcase if self.name 
    self.parent_id = nil if self.parent_id == -1
  end

  def is_sub_category?
    !parent_id.blank?
  end

  def self.get_categories(is_admin=false)
    having_cache ["categories_"], {:expires_in => CACHE_TIMEOUT, :force => is_admin }  do
      find(:all, :order=>"name asc")
    end
  end

  def self.get_category(seo_name)
    having_cache ["category_", seo_name], {:expires_in => 1.year, :force => false }  do
      find(:first, :conditions=>["seo_name=?", seo_name])
    end
  end
  
  def get_posts(page, is_admin)
    having_cache ["posts_", page, is_admin], {:expires_in => CACHE_TIMEOUT, :force => is_admin }  do
      posts.paginate({ :page => page, :order => "posts.created_at desc" })
    end
  end 

  def to_s
    name
  end

  def to_param
    begin 
      "#{id}-#{to_s.parameterize}"
    rescue
      "#{id}"
    end
  end
    
end
