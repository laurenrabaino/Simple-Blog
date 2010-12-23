class Page < ActiveRecord::Base

  extend ActiveSupport::Memoizable
  include ActiveSupport::Memoizable
  
  include ActionController::UrlWriter
  default_url_options[:host] = SETTINGS[:site][:host]
  
  cattr_accessor :per_page
  @@per_page = 10
  
  acts_as_taggable
  #acts_as_solr :fields => [:title, :body]
  
  # author, author_email, title, content, permalink.
  acts_as_defensio_article :fields => { :content => :body  }
  
  after_create :publish
  
  has_many :comments, :as => :commentable, :dependent => :destroy, :conditions => "comments.parent_id is null"
  has_many :favorites, :as => :favoriteable, :dependent => :destroy
  has_many :clickstreams, :as => :clickstreamable, :dependent => :destroy
  has_many :features, :as => :featurable, :dependent => :destroy
  
  belongs_to :user
  
  validates_presence_of :title, :on => :create, :message => I18n.t('errors.title')
  validates_presence_of :body, :on => :create, :message => I18n.t('errors.body')
  
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
       :message      => I18n.t('errors.featuredimage.format'),
       :unless => :featured_image_name

     validates_attachment_size :featured_image, :in => 0..3.megabytes, :message      => I18n.t('errors.featuredimage.size'), :unless => :featured_image_name
   end
  
  
  named_scope :published, :conditions=>"pages.status=1"
  named_scope :top_menu, :conditions=>"top_menu=1"

  named_scope :apply_filter_to_list, lambda{ |filter_name|
    f = FILTERS[filter_name] || FILTERS['recency']
    options = {}
    options[:order] = f[:ordering].gsub('TABLE_NAME', 'pages') if f[:ordering]
    options[:conditions] = f[:conditions].gsub('TABLE_NAME', 'pages') if f[:conditions]
    options
  }
  
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
      self.published.top_menu.all
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
            :comment => comment })
      
      # only email if the parent comment is not yours...
      Notifier.deliver_new_comment_reply({:commentable => {:title => title, :email => comment.parent_comment.author_email, :author => comment.parent_comment.article_author, :permalink => permalink, :type => I18n.t("common.article").capitalize}, 
            :comment => comment, :parent_comment => comment.parent_comment }) if comment.parent_comment && author_email!=comment.parent_comment.author_email
    end
  end
  
end