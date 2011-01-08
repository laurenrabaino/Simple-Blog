class Page < ActiveRecord::Base

  extend ActiveSupport::Memoizable
  include ActiveSupport::Memoizable
  
  include ActionController::UrlWriter
  default_url_options[:host] = SETTINGS[:site][:host]
  
  cattr_accessor :per_page
  @@per_page = 10
  
  acts_as_taggable
  
  # author, author_email, title, content, permalink.
  acts_as_defensio_article :fields => { :content => :body  }
  
  after_create :publish
  
  has_many :comments, :as => :commentable, :conditions => "comments.parent_id is null"
  has_many :all_comments, :as => :commentable, :dependent => :destroy, :class_name=>"Comment"
  has_many :favorites, :as => :favoriteable, :dependent => :destroy
  has_many :clickstreams, :as => :clickstreamable, :dependent => :destroy
  has_many :features, :as => :featurable, :dependent => :destroy
  
  belongs_to :user
  belongs_to :profile, :foreign_key => "user_id", :class_name=>"User", :touch => true
  
  validates_presence_of :title, :on => :create, :message => I18n.t('errors.page.title')
  validates_presence_of :body, :on => :create, :message => I18n.t('errors.page.body')
  
  has_attached_file :featured_image, 
    :styles => { :large => "600x600>", :medium => "300x300>", :thumb => "100x100>" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :bucket =>   S3_BUCKET,
    :path => "pages/" <<
             ":attachment/:id_partition/" <<
             ":basename_:style.:extension",
    :url =>  "pages/:attachment/:id_partition/" <<
             ":basename_:style.:extension"
   
   unless Rails.env.development?
     validates_attachment_content_type :featured_image,
       :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                         'image/x-png', 'image/jpg'],
       :message      => I18n.t('errors.page.image.format'),
       :unless => :featured_image_name

     validates_attachment_size :featured_image, :in => 0..3.megabytes, :message      => I18n.t('errors.page.image.size'), :unless => :featured_image_name
   end
  
  
  named_scope :published, :conditions=>"pages.status=1"
  named_scope :top_menu, :conditions=>"top_menu=1", :order=>'title asc'
  named_scope :not_home_page, :conditions=>"is_home_page=0"

  named_scope :apply_filter_to_list, lambda{ |filter_name|
    f = FILTERS[filter_name] || FILTERS['recency']
    options = {}
    options[:order] = f[:ordering].gsub('TABLE_NAME', 'pages') if f[:ordering]
    options[:conditions] = f[:conditions].gsub('TABLE_NAME', 'pages') if f[:conditions]
    options
  }
  
  # only include sphinx methods if it is running...
  if SPHINX_SEARCH
    define_index do
      indexes title, :sortable => true
      indexes excerpt, :sortable => true
      indexes body, :sortable => true
    
      has created_at, updated_at
    
      set_property :delta => :delayed
    end
  end
  
  def self.get_pages(page, is_admin=false)
    having_cache ["index_pages_", page, @@per_page], {:expires_in => CACHE_TIMEOUT, :force => is_admin } do
      paginate(:page=>params[:page])
    end
  end
  
  def self.is_home_page?(is_admin=false)
    having_cache ["is_home_page_page_"], {:expires_in => CACHE_TIMEOUT, :force => is_admin } do
      find_by_is_home_page(true)
    end
  end
  
  def self.get_search(search_term, page, is_admin=false)
    having_cache ["search_pages_", page, search_term, @@per_page, SPHINX_SEARCH], {:expires_in => CACHE_TIMEOUT, :force => is_admin } do
      return search search_term, :order => :created_at, :sort_mode => :desc, :page => page, :per_page => @@per_page if SPHINX_SEARCH
      search_term = "%#{search_term}%"
      return paginate({:page=>page, :conditions=>["title like ? OR body like ? OR excerpt like ?", search_term, search_term, search_term]})
    end
  end
  
  def self.tagged_with(tag, page, is_admin=false)
    having_cache ["tags_pages_", page, tag, @@per_page], {:expires_in => CACHE_TIMEOUT, :force => is_admin } do
      find_tagged_with(tag).paginate({:page => @page, :per_page => @@per_page})
    end
  end
  
  def author
    (user ? user.user_name : "Anonymous")
  end
  
  def author_email
    (user ? user.email : "anonymous")
  end
  
  def permalink
    page_path(self, {:only_path => false})
  end
  
  def featured_image_name
    featured_image_file_name.blank?
  end
  
  def self.get_menu_pages(is_admin=false)
    having_cache ["page_top_menu", is_admin], {:expires_in => CACHE_TIMEOUT, :force => is_admin } do
      self.not_home_page.published.top_menu.all
    end
  end
  
  def excerpt?
    return excerpt unless excerpt.blank?
    short_body = body.length>300 ? body[0..300].gsub(/\w+$/, '')+"..." : body
    return short_body
  end
  memoize :excerpt?
  
  def published?
    status==1
  end
  
  def publish
    self.status=1
    self.save
  end
  
  def to_s
    title
  end
  
  def to_param
    begin 
      "#{id}-#{to_s.parameterize}"
    rescue
      "#{id}"
    end
  end
  
  def new_comment_published(comment)
    # only email if the comment is not yours...
    if author_email!=comment.author_email
      Notifier.deliver_new_comment_published({:commentable => {:title => title, :email => author_email, :author => author, :permalink => permalink, :type => I18n.t("common.page.display").capitalize}, 
            :comment => comment }) unless author_email=='anonymous'
      
      # only email if the parent comment is not yours...
      Notifier.deliver_new_comment_reply({:commentable => {:title => title, :email => comment.parent_comment.author_email, :author => comment.parent_comment.article_author, :permalink => permalink, :type => I18n.t("common.article").capitalize}, 
            :comment => comment, :parent_comment => comment.parent_comment }) if comment.parent_comment && author_email!=comment.parent_comment.author_email && comment.parent_comment.author_email!='anonymous'
    end
  end
  
end