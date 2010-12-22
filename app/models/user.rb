class User < ActiveRecord::Base
  
  extend ActiveSupport::Memoizable
  include ActiveSupport::Memoizable
  
  include OauthConnect
  
  has_one :twitter_account, :dependent => :destroy
  has_one :facebook_account, :dependent => :destroy
  has_many :notify_settings
  
  #has_many :favorites, :as => :favoriteable, :dependent => :destroy
  has_many :clickstreams, :as => :clickstreamable, :dependent => :destroy
  #has_many :features, :as => :featurable, :dependent => :destroy
  
  after_create :post_process
  
  attr_accessor :send_confirmation
  @@send_confirmation = true
  
  attr_accessor :locale
  @@locale = "es"
  
  cattr_accessor :per_page
  @@per_page = 10
  
  validates_uniqueness_of   :email, :on => :create, :message => I18n.t('errors.emailtaken')
  validates_uniqueness_of   :user_name, :on => :create, :message => I18n.t('errors.usernametaken'), :unless => :check_status
  validates_uniqueness_of   :user_name, :message => I18n.t('errors.usernametaken'), :if => :check_temporary_user
  validates_presence_of     :email, :on => :create, :message => I18n.t('errors.emailblank')
  validates_presence_of     :user_name, :on => :create, :message => I18n.t('errors.usernameblank'), :unless => :check_status
  validates_presence_of     :user_name, :message => I18n.t('errors.usernameblank'), :if => :check_temporary_user
  validates_length_of       :password, :within => 4..40, :on => :create, :message => I18n.t('errors.passwordinvalid')
  validates_length_of       :email, :within => 3..100, :on => :create, :message => I18n.t('errors.emailtooshort')
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => I18n.t('errors.emailinvalid')
  
  has_attached_file :avatar, 
    :styles => { :large => "200x200#", :medium => "100x100#", :thumb => "50x50#" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :bucket =>   S3_BUCKET,
    :path        => "profiles/" <<
                    ":attachment/:id_partition/" <<
                    ":basename_:style.:extension",
    :url         => "profiles/:attachment/:id_partition/" <<
                    ":basename_:style.:extension",
    :default_url => "/images/default_avatar_:style.png"
             
  unless Rails.env.development?
    validates_attachment_content_type :avatar,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                        'image/x-png', 'image/jpg'],
      :message      => I18n.t('errors.featuredimage.format'),
      :unless => :avatar_name

    validates_attachment_size :avatar, :in => 0..3.megabytes, :message => I18n.t('errors.featuredimage.size'), :unless => :avatar_name
  end
  
  def check_temporary_user
    status.to_i == 1
  end
  
  def check_status
    status.to_i == 0
  end
  
  def avatar_name
    avatar_file_name.blank?
  end
  
  def self.info_account
    find(:first, :conditions => "user_name='info'")
  end
  
  def is_admin?
    is_admin
  end
  memoize :is_admin?
  
  def show_profile_link?
    return false
    settings.is_public if self.is_a? Profile
    false
  end
  memoize :show_profile_link?
  
  def check_activation_code?
    activation_code==generate_activation_code
  end
  memoize :check_activation_code?
  
  def generate_activation_code
    Digest::SHA1.hexdigest("--#{SETTINGS[:site][:salt]}--#{password}--#{created_at}--#{user_name}--")
  end
  memoize :generate_activation_code
  
  def post_process
   set_activation_code
   update_user if send_confirmation
   update_admin if status==1
  end
  
  def send_confirmations
    update_user
  end
  
  def update_user
    Notifier.deliver_account_confirmation(email, {:user=>self, :locale=>locale})
  end
  
  def set_activation_code
    self.activation_code = generate_activation_code
    self.save
  end
  
  def to_s
    user_name
  end

  def to_param
    begin 
      "#{id}-#{to_s.parameterize}"
    rescue
      "#{id}"
    end
  end
  
  def has_twitter_oauth?
    self.twitter_account && self.twitter_account.token && self.twitter_account.secret
  end
  
  def has_facebook_oauth?
    self.facebook_account && self.facebook_account.fb_user_id && self.facebook_account.code 
  end
  
  def post_fb_wall(args)
    #unless Rails.env.development?
      fb_account = args[:facebook_account_id] ? FacebookAccount.find_by_id(args[:facebook_account_id]) : facebook_account
      return false if args[:message].blank? || !fb_account || fb_account.code.blank?
      begin
        query_string = args.collect {|k,v| "#{k.to_s}=#{v}" if v}.to_a.compact.uniq.join("&")
        access_token = fb_access_token(fb_account.code) 
        access_token.post('/me/feed?' + query_string) if access_token
      rescue
      end
    #end
  end
  
  def get_setting?(type)
    setting = notify_settings.find(:first, :conditions => ['notify_type=?', type])
    setting = self.notify_settings.create({ :user_id => id, :notify_type => type, :value => true }) unless setting
    setting.value
  end
  
end