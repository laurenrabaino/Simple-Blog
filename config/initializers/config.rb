FILTERS = ActiveSupport::OrderedHash.new
FILTERS["viewed"] = { :display_name => I18n.t("common.filter.viewed"), :link => '/viewed', :ordering => "TABLE_NAME.viewed desc, TABLE_NAME.created_at desc" }
FILTERS["favorited"] = { :display_name => I18n.t("common.filter.favorited"), :link => '/favorited', :ordering => "TABLE_NAME.favorited desc, TABLE_NAME.created_at desc", :conditions => 'TABLE_NAME.favorited>0' }
FILTERS["featured"] = { :display_name => I18n.t("common.filter.featured"), :link => '/featured', :ordering => "TABLE_NAME.featured_at desc, TABLE_NAME.created_at desc", :conditions => 'TABLE_NAME.featured=1' }
FILTERS["recency"] = { :display_name => I18n.t("common.filter.recency"), :link => '/', :ordering => "TABLE_NAME.created_at desc" }

SUBSCRIBE = SETTINGS[:social][:subscribe].reject{ |key, value| value.blank? }

SUBSCRIBE_IMAGES = {}
SUBSCRIBE_IMAGES[:facebook] = "fb_logo.jpg"
SUBSCRIBE_IMAGES[:twitter] = "tw_logo.jpg"
SUBSCRIBE_IMAGES[:blogtalkradio] = "blogtalkradio.jpg"
SUBSCRIBE_IMAGES[:youtube] = "yt_logo.png"
SUBSCRIBE_IMAGES[:itunes] = "itunes.png"
SUBSCRIBE_IMAGES[:flickr] = "fk_logo.png"

S3_BUCKET = SETTINGS[:s3][:bucket]

# Load mail configuration if not in test environment
if RAILS_ENV != 'test'
  email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
  ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
end

SPHINX_SEARCH = SETTINGS[:search] && !SETTINGS[:search].blank? && SETTINGS[:search]=='sphinx'