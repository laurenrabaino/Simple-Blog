# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  BOT_FILTER = /(?:Googlebot|Slurp|Apache|msnbot|wget|libwww|nutch|ia_archiver|heretrix|cuil|google|yandex)/i
  
  after_filter :minify_html, :unless => Proc.new { Rails.env.development? }
  after_filter :save_clickstream, :if => :save_clickstream?
  before_filter :preload_models, :unless => Proc.new { Rails.env.production? }
  before_filter :check_home_page
  before_filter :user_authorization, :unless => :no_before_filters
  before_filter :set_base_header_info, :unless => :no_before_filters
  before_filter :get_pages, :unless => :no_before_filters
  
  include CacheConcerns::ControllerMethods                                                # Core concerns
  
  def get_pages
    @menu_pages = Page.get_menu_pages(logged_in_and_admin)
  end
  
  def login_required
    redirect_to "/" unless @current_user
  end
  
  def no_before_filters
    params[:controller]=='sitemap'
  end
  
  def is_admin
    #head :bad_request unless @current_user && @current_user.is_admin?
  end
  
  def logged_in_and_admin
    @current_user && @current_user.is_admin?
  end
  
  def preload_models
    Post
    CacheConcerns
  end
  
  def set_base_header_info
    @header = {}
    @header[:title] = []
    @header[:title] << SETTINGS[:site][:name]
    @header[:description] = SETTINGS[:site][:description]
    @header[:keywords] = SETTINGS[:site][:keywords]
  end
  
  def save_clickstream?
    params[:controller]!='sitemap' && params[:controller]!='comments' && params[:controller]!='admin'
  end
  
  def save_clickstream
    
    return if @current_user && @current_user.is_admin? 
    
    arg = {}

    user_agent = request ? request.user_agent : nil
    return if user_agent =~ BOT_FILTER

    user_agent = user_agent[0,255] if user_agent && user_agent.size > 256

    arg[:ip] = request.remote_ip if request
    arg[:url] = request.request_uri if request
    arg[:session_id] = session.session_id if session && !session.empty?
    arg[:user_agent] = user_agent
    arg[:user_id] = session[:user_id]
    arg[:referer] = request.env["HTTP_REFERER"]

    if @page && @page.is_a?(Page)
      arg[:clickstreamable_type] = 'Page'
      arg[:clickstreamable_id] = @page.id
    elsif @profile
      arg[:clickstreamable_type] = 'Profile'
      arg[:clickstreamable_id] = @profile.id
    elsif @post
      arg[:clickstreamable_type] = 'Post'
      arg[:clickstreamable_id] = @post.id
    end

    Clickstream.create(arg) if arg && !arg.empty?
    
  end
  
  def user_authorization
    @current_user = nil
    @current_user = Profile.find_by_id(session[:user_id]) if session[:user_id]
  end
  
  def minify_html
    response.body.gsub!(/[ \t\v]+/, ' ')
    response.body.gsub!(/\s*[\n\r]+\s*/, "\n")
    response.body.gsub!(/>\s+</, '> <')
    response.body.gsub!(/<\!\-\-([^>\n\r]*?)\-\->/, '')
  end
  
  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = cookies[:locale] if cookies[:locale]
    cookies[:locale] = SETTINGS[:site][:locale] unless cookies[:locale]
  end
  
  def get_locale
    (cookies[:locale] ? cookies[:locale] : SETTINGS[:site][:locale])
  end     
  
  def reset_home_page
    Page.update_all("is_home_page=0")
    Post.update_all("is_home_page=0")
  end
  
  def check_home_page
    @home_post = Post.is_home_page?(logged_in_and_admin)
    @home_page = @home_post ? nil : Page.is_home_page?(logged_in_and_admin)
    @show_blog_link = !@home_post.blank? || !@home_page.blank? 
  end
  
end
