class Comment < ActiveRecord::Base

  extend ActiveSupport::Memoizable
  include ActiveSupport::Memoizable
  
  #author, content, title, author_email, author_url, article.permalink, trusted_user and logged_in
  acts_as_defensio_comment :fields => { :content => :body, :article => :commentable  }
  
  after_create :update_admins
  
  cattr_accessor :per_page
  @@per_page = 10
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :user, :touch => true
  belongs_to :profile, :foreign_key => :user_id
  
  belongs_to :parent_comment, :class_name => 'Comment', :foreign_key => "parent_id", :touch => true
  has_many :replies, :class_name => "Comment", :foreign_key => 'parent_id', :conditions => 'spam!=1 OR spaminess<=0.75'

  validates_presence_of :full_name, :on => :create, :message => I18n.t("form.comment.full_name")
  validates_presence_of :email, :on => :create, :message => I18n.t("form.comment.email")
  validates_presence_of :body, :on => :create, :message => I18n.t("form.comment.body.empty")
  validates_length_of :body, :maximum => 1000, :on => :create, :message => I18n.t("form.comment.body.length")
  
  named_scope :just_spam, :conditions => 'spam=1 OR spaminess>0.75'
  named_scope :just_ham, :conditions => 'spam!=1 AND spaminess<=0.75'
  
  # only include sphinx methods if it is running...
  if SPHINX_SEARCH
    define_index do
      indexes body, :sortable => true

      has user_id, created_at, updated_at
    end
  end
  
  def self.get_search(search_term, page, is_admin)
    having_cache ["search_comments_", page, search_term, @@per_page, SPHINX_SEARCH], {:expires_in => CACHE_TIMEOUT, :force => is_admin } do
      return search search_term, :order => :created_at, :sort_mode => :desc, :page => page, :per_page => @@per_page if SPHINX_SEARCH
      search_term = "%#{search_term}%"
      return paginate({:page=>page, :conditions=>["body like ?", search_term]})
    end
  end
  
  def title
    if body
      short_body = body.length>300 ? body[0..300].gsub(/\w+$/, '')+"..." : body
    else
      short_body = ""
    end
    
    return short_body
  end
  
  def author
    (profile ? profile.user_name : "Anonymous")
  end
  
  def author_name
    (profile ? profile.user_name : full_name)
  end
  
  # helper methods for validations
  def author_email
    (profile ? profile.email : email)
  end
  
  def author_url
    (profile ? profile.permalink : "")
  end
  
  def trusted_user
    profile && profile.is_admin?
  end
  
  def logged_in
    !profile.blank?
  end
  
  def not_spam?
    !spam && spaminess<0.75
  end
  
  def new_comment_published
    commentable.new_comment_published(self) if commentable && commentable.respond_to?(:new_comment_published) && not_spam?
  end
  
  def update_admins   
    new_comment_published 
    #update_twitter_and_facebook
  end
  
  def update_twitter_and_facebook
    share_types = SharedPost.find(:all, :conditions => ["user_id=? and shareable_type=? and shareable_id=?", profile.id, 'Comment', self.id]).map(&:share_type)
    update_twitter(profile) unless share_types.include?('Twitter')
    update_facebook_wall(profile) unless share_types.include?('Facebook')
  end
  
  def update_twitter(u = nil, twitter_account=nil)
    if u && (u.twitter_account || twitter_account)
      u.twitter_account.update_status(status_update) unless twitter_account
      twitter_account.update_status(status_update) if twitter_account
      SharedPost.create({ :user_id => u.id, :share_type =>'Twitter', :shareable_type => 'Comment', :shareable_id => self.id })
    end
  end
  
  def update_facebook_wall(u = nil, facebook_account=nil)
    if u && (u.facebook_account || facebook_account)
      args = {:message => t("common.commented") + commentable.status_update(false), 
        :description => strip_html(commentable.excerpt?), 
        :link => commentable.permalink,  
        :name => commentable.title
      }
      args[:facebook_account_id] = facebook_account.id if facebook_account
      u.post_fb_wall(args)
      SharedPost.create({ :user_id => u.id, :share_type =>'Facebook', :shareable_type => 'Comment', :shareable_id => self.id })
    end
  end
  
  
end