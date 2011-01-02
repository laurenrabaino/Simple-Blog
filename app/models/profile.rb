class Profile < User
  
  include Utils
  include ActionController::UrlWriter
  default_url_options[:host] = SETTINGS[:site][:host]
  
  cattr_accessor :per_page
  @@per_page = 10
  
  attr_accessor :confirm_password
  attr_accessor :override
  attr_accessor :terms_of_use
  
  # define settings association
  has_one :settings, :foreign_key => :user_id, :class_name => "Setting"
  
  # define content associations
  has_many :comments, :foreign_key => :user_id
  has_many :posts, :foreign_key => :user_id
  
  # define the validation functions  
  validates_acceptance_of   :terms_of_use, :on => :create, :message => I18n.t('errors.profile.termsofuse'), :unless => :check_status
  validates_acceptance_of   :terms_of_use, :message => I18n.t('errors.profile.termsofuse'), :if => :check_temporary_user
  
  named_scope :admins, :conditions => 'is_admin=1'
  named_scope :all_profiles, :order => "user_name asc"
  
  def permalink
    profile_path(self, { :only_path => false })
  end
  
  def validate
    errors.add('passwords_do_not_match', I18n.t('errors.profile.passwordsdonotmatch')) unless confirm_password == password 
  end
     
  def short_about_me
    short_about_me = nil
    short_about_me = (settings.about_me.length>100 ? settings.about_me[0..100].gsub(/\w+$/, '')+"..." : settings.about_me) if settings && settings.about_me && !settings.about_me.strip.blank?
    return short_about_me
  end
  memoize :short_about_me
    
  def get_comments(page, is_admin=false)
    having_cache ["profile_comments_", self, page, @@per_page], { :expires_in => CACHE_TIMEOUT, :force => is_admin }  do
       comments.paginate(:page=>page, :order=>'comments.created_at desc')
    end
  end  
  
  def get_posts(page, is_admin=false)
    having_cache ["profile_posts_", self, page, @@per_page], { :expires_in => CACHE_TIMEOUT, :force => is_admin }  do
       posts.paginate(:page=>page, :order=>'posts.created_at desc')
    end
  end
  
  def generate_temporary_password(send_email=false)
    self.confirm_password = self.password
    self.update_attributes({:temporary_password => ActiveSupport::SecureRandom.base64(6), :temporary_password_hash => Digest::SHA1.hexdigest("--#{SETTINGS[:site][:salt]}--#{password}--#{Time.now}--#{ActiveSupport::SecureRandom.base64(6)}--")})
    Notifier.deliver_new_password(email, {:user => self, :locale => locale}) if send_email
  end
  
  def editor?
    is_admin
  end
    
end