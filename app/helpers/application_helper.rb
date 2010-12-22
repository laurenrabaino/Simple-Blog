# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
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
  
  def correct_body(body, object=nil)
    tmp = body.sanitize if body
    return tmp
  end
  
  def active_menu?
    return 'comments' if params[:controller]=='comments'
    return 'profiles' if @profile || params[:controller]=='profiles'
    return 'pages' if  (@page && @page.is_a?(Page)) || params[:controller]=='pages'
    return 'posts' if @post || params[:controller]=='posts'
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
  
end
