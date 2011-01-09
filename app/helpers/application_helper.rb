# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def apply_fragment(key, options = {}, &block)    
    options[:skip] ? block.call : cache(reduce_cache_key(key), options, &block)
  rescue Memcached::Error
    block.call
  end
  
  def reduce_cache_key(key)
    final_key = ActiveSupport::Cache.expand_cache_key(key)
    final_key.gsub!(" ","")
    locale_key = cookies[:locale] ? cookies[:locale] : "es"
    Digest::SHA1.hexdigest(locale_key + final_key)
  end
  
  def is_admin?
    (@current_user && @current_user.is_admin?)
  end
  
  def is_super_admin?
    (@current_user && @current_user.is_admin?)
  end
  
  def transform_embed_code(embed_code, width, height)
    embed_code = embed_code.gsub(/width="([0-9]+)"/, "width='#{width}'")
    embed_code = embed_code.gsub(/width:"([0-9]+)"/, "width:'#{width}'")
    embed_code = embed_code.gsub(/height="([0-9]+)"/, "height='#{height}'")
    embed_code = embed_code.gsub(/height:"([0-9]+)"/, "height:'#{height}'")
    embed_code
  end
  
  def parse_xml_created_at(xml, posts)
    unless posts.empty?
      xml.pubDate posts.first.created_at.to_s(:rfc822) 
      xml.lastBuildDate posts.first.created_at.to_s(:rfc822)
    else
      xml.pubDate Time.now.to_s(:rfc822) 
      xml.lastBuildDate Time.now.to_s(:rfc822)
    end
  end

  def truncate_words(text, length = 30, end_string = '&hellip; ')
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end
  
  def correct_body(body, object=nil)
    tmp = body.sanitize if body
    return tmp
  end
  
  def active_menu?
    return 'comments' if params[:controller]=='comments'
    return 'profiles' if @profile || params[:controller]=='profiles'
    return 'pages' if  (@page && @page.is_a?(Page)) || params[:controller]=='pages'
    return 'posts' if @post || params[:controller]=='posts'
    return 'categories' if @category || params[:controller]=='category'
    return 'posts'
  end
  
  def getAdminMenuClass(menu_item)
    return "class='active'" if active_menu? == menu_item
    ""
  end
  
  def showAdminMenu?(menu_item)
    return "" if active_menu? == menu_item
    return "style='display:none;'"
  end
  
  def shared?(type, id, notification_type)
    share_types = SharedPost.find(:all, :conditions => ["user_id=? and shareable_type=? and shareable_id=?", @current_user.id, type, id]).map(&:share_type)
    share_types.include?(notification_type)
  end
  
  def tag_cloud(tags, classes)
    max_count = tags.sort_by(&:count).last.count.to_f
    
    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end

  # get the stylesheets...
  def get_stylesheets(is_admin=false)
    stylesheets = ['base', 'main', 'style', '/javascripts/facebox']
    stylesheets.collect! { |s| File.exists?("#{Rails.public_path}/stylesheets/custom/#{s}.css") ? "custom/#{s}" : s }
    stylesheets << 'admin' if is_admin
    stylesheets << "post" if @post || (@page && @page.is_a?(Page))
    stylesheets << "profile" if @profile
    stylesheets << "static" if params[:controller]=="statics"
    stylesheet_link_tag stylesheets, :media => "all", :concat => stylesheet_name?(stylesheets), :cache => true
  end
  
  def stylesheet_name?(stylesheets)
    names = ['global']
    names << "admin" if stylesheets.detect { |s| s =~ /(?:admin)/i }  
    names << "custom" if stylesheets.detect { |s| s =~ /(?:custom)/i }
    names << "post" if @post || (@page && @page.is_a?(Page))
    names << "profile" if @profile
    names << "static" if params[:controller]=="statics"
    "cache/#{names.join('_')}"
  end
  
end
