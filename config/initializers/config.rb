FILTERS = ActiveSupport::OrderedHash.new
FILTERS["viewed"] = { :display_name => I18n.t("common.filter.viewed"), :link => '/viewed', :ordering => "TABLE_NAME.viewed desc, TABLE_NAME.created_at desc" }
FILTERS["favorited"] = { :display_name => I18n.t("common.filter.favorited"), :link => '/favorited', :ordering => "TABLE_NAME.favorited desc, TABLE_NAME.created_at desc", :conditions => 'TABLE_NAME.favorited>0' }
FILTERS["featured"] = { :display_name => I18n.t("common.filter.featured"), :link => '/featured', :ordering => "TABLE_NAME.featured_at desc, TABLE_NAME.created_at desc", :conditions => 'TABLE_NAME.featured=1' }
FILTERS["recency"] = { :display_name => I18n.t("common.filter.recency"), :link => '/', :ordering => "TABLE_NAME.created_at desc" }