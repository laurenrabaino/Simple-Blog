class Post < ActiveRecord::Base
  
  include Utils
  include ActionController::UrlWriter
  default_url_options[:host] = SETTINGS[:site][:host]
  
  attr_accessor :notify_facebook
  attr_accessor :notify_twitter
  
  after_create :update_admins
  
  cattr_accessor :per_page
  @@per_page = 10
  
  acts_as_taggable
  
  # author, author_email, title, content, permalink.
  acts_as_defensio_article :fields => { :content => :body, :author => :post_author  }
  
  extend ActiveSupport::Memoizable
  include ActiveSupport::Memoizable
  
  has_many :comments, :as => :commentable, :dependent => :destroy, :conditions => "comments.parent_id is null"
  #has_many :favorites, :as => :favoriteable, :dependent => :destroy
  has_many :clickstreams, :as => :clickstreamable, :dependent => :destroy
  #has_many :features, :as => :featurable, :dependent => :destroy
  
  belongs_to :profile, :foreign_key => "user_id", :class_name=>"User", :touch => true
  
  has_and_belongs_to_many :categories
  
  validates_presence_of :title, :on => :create, :message => I18n.t('errors.blog.title')
  validates_presence_of :body, :on => :create, :message => I18n.t('errors.blog.body')
  
  has_attached_file :featured_image, 
    :styles => { :large => "600x600>", :carousel => "300x300#", :medium => "260x120#", :thumb => "100x100#" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :bucket =>   S3_BUCKET,
    :path => "posts/" <<
             ":attachment/:id_partition/" <<
             ":basename_:style.:extension",
    :url =>  "posts/:attachment/:id_partition/" <<
             ":basename_:style.:extension"
             
  unless Rails.env.development?
    validates_attachment_content_type :featured_image,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                        'image/x-png', 'image/jpg'],
      :message      => I18n.t('errors.blog.image.format'),
      :unless => :featured_image_name

    validates_attachment_size :featured_image, :in => 0..3.megabytes, :message      => I18n.t('errors.blog.image.size'), :unless => :featured_image_name
  end
  
  named_scope :published, :conditions => "posts.status=1"
  
  named_scope :apply_filter_to_list, lambda{ |filter_name|
    f = FILTERS[filter_name] || FILTERS['recency']
    options = {}
    options[:order] = f[:ordering].gsub('TABLE_NAME', 'posts') if f[:ordering]
    options[:conditions] = f[:conditions].gsub('TABLE_NAME', 'posts') if f[:conditions]
    options
  }
  
  def self.get_posts_index(page, filter_name='recency', is_admin=false)
      having_cache ["index_page_posts_new", page, filter_name, is_admin, @@per_page], {:expires_in => CACHE_TIMEOUT, :force => is_admin }  do
        if is_admin
          apply_filter_to_list(filter_name).paginate(:page => page)
        else
          published.apply_filter_to_list(filter_name).paginate(:page => page)
        end
      end
  end
  
  def self.get_tags(is_admin=false)
    having_cache ["tags_", is_admin], {:expires_in => 24*60*60, :force => is_admin }  do
      self.tag_counts(:limit => 20)
    end
  end
  
  # helper methods for validations
  def post_author
    profile.user_name
  end
  
  def author_email
    profile.email
  end
  
  def permalink
    post_path(self, {:only_path => false})
  end
  
  def featured_image_name
    featured_image_file_name.blank?
  end
  #  end helper methods for validations
  
  def status_update(show_url=true)
    bitly = short_url(permalink)
    url_length = show_url ? bitly.length : 0
    max_length = 140 - (PREPEND_STATUS_UPDATE.length + url_length + 23)
    msg  = "#{PREPEND_STATUS_UPDATE}: "
    msg += title.length > max_length ? "#{title[0..max_length].gsub(/\w+$/, '')}..." : title
    msg += " - #{bitly}" if show_url
    msg
  end
  
  def short_url(url)
    authorize = UrlShortener::Authorize.new SETTINGS[:bitly][:login], SETTINGS[:bitly][:api_key]
    client = UrlShortener::Client.new(authorize)
    shorten = client.shorten("#{url}")
    shorten.urls
  end
  
  def excerpt?
    return excerpt unless excerpt.blank?
    if body
      short_body = body.length>600 ? body[0..600].gsub(/\w+$/, '')+"..." : body
    else
      short_body = ""
    end
    
    return short_body
  end
  memoize :excerpt?
  
  def published?
    status==1
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
      Notifier.deliver_new_comment_published({:commentable => {:title => title, :email => author_email, :author => article_author, :permalink => permalink, :type => I18n.t("common.blog.display").capitalize}, 
            :comment => comment })
      
      # only email if the parent comment is not yours...
      Notifier.deliver_new_comment_reply({:commentable => {:title => title, :email => comment.parent_comment.author_email, :author => comment.parent_comment.article_author, :permalink => permalink, :type => I18n.t("common.article").capitalize}, 
            :comment => comment, :parent_comment => comment.parent_comment }) if comment.parent_comment && author_email!=comment.parent_comment.author_email
    end
  end
  
  def update_admins
    Notifier.deliver_new_post_update(Profile.admins.all.map(&:email), {:post => self}) unless tweeted
    
    if OauthConnect.has_twitter? || OauthConnect.has_facebook?
      info_account = User.info_account
      update_twitter_and_facebook(info_account)
    end
  end
  
  def update_twitter_and_facebook_for_a_user(u, twitter_account, facebook_account)
    update_twitter(u, twitter_account) if OauthConnect.has_twitter?
    update_facebook_wall(u, facebook_account) if OauthConnect.has_facebook?
  end
  
  def update_twitter_and_facebook(info_account=nil)
    share_types = SharedPost.find(:all, :conditions => ["user_id=? and shareable_type=? and shareable_id=?", profile.id, 'Post', self.id]).map(&:share_type)
    update_twitter(profile) unless share_types.include?('Twitter') || (info_account && info_account.id == profile.id)
    update_facebook_wall(profile) unless share_types.include?('Facebook') || (info_account && info_account.id == profile.id)

    if info_account
      self.notify_twitter = 1
      self.notify_facebook = 1
      share_types = SharedPost.find(:all, :conditions => ["user_id=? and shareable_type=? and shareable_id=?", info_account.id, 'Post', self.id]).map(&:share_type)
      update_twitter(info_account) unless share_types.include?('Twitter')
      update_facebook_wall(info_account) unless share_types.include?('Facebook')
      self.update_attributes({ :tweeted => true }) if info_account.twitter_account
      self.update_attributes({ :facebooked => true }) if info_account.facebook_account
    end
  end
  
  def update_twitter(u = nil, twitter_account=nil)
    return unless OauthConnect.has_twitter?
    if u && (u.twitter_account || twitter_account) && self.notify_twitter.to_i==1
      u.twitter_account.update_status(status_update) unless twitter_account
      twitter_account.update_status(status_update) if twitter_account
      SharedPost.create({ :user_id => u.id, :share_type =>'Twitter', :shareable_type => 'Post', :shareable_id => self.id })
    end
  end
  
  def update_facebook_wall(u = nil, facebook_account=nil)
    return unless OauthConnect.has_facebook?
    if u && (u.facebook_account || facebook_account) && self.notify_facebook.to_i==1
      args = {:message => status_update(false), 
        :description => strip_html(excerpt?), 
        :link => permalink,  
        :name => title
      }
      args[:picture] = self.featured_image.url(:thumb) if self.featured_image.file?
      args[:facebook_account_id] = facebook_account.id if facebook_account
      u.post_fb_wall(args)
      SharedPost.create({ :user_id => u.id, :share_type =>'Facebook', :shareable_type => 'Post', :shareable_id => self.id })
    end
  end
  
end
