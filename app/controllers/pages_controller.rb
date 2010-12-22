class PagesController < ApplicationController
  resources_controller_for :pages
  
  before_filter :is_admin
  
  def show
    @page = find_resource
    @header[:title] << t("common.page.display").capitalize
    @header[:title] << @page.title
    @header[:description] = @page.excerpt?
  end
  
  def index
    @header[:title] << t("common.page.display").capitalize
    @pages = Page.active_site.paginate(:page=>params[:page])
  end
  
  def publish
    @page = find_resource
    @page.status = 1
    @page.save
    flash[:notice] = "You have published this page!"
    redirect_to :back
  end
  
  def unpublish
    @page = find_resource
    @page.status = 0
    @page.save
    flash[:notice] = "You have unpublished this page!"
    redirect_to :back
  end
  
  def favorite
    @page = find_resource
    favorite = @page.favorites.create({ :ip => request.remote_ip, :user_id => session[:user_id] })
    @page.favorited = @page.favorited ? (@page.favorited.to_i + 1) : 1
    @page.save
    redirect_to :back
  end
  
  def featured
    @page = find_resource
    favorite = @page.features.create({ :ip => request.remote_ip, :user_id => session[:user_id] }) unless @page.features.find_by_user_id(@current_user.id)
    @page.featured_at = Time.now
    @page.featured = true
    @page.save
    redirect_to :back
  end
  
  protected
  
  def create_page_site(site_id, page_id)
    ps = PagesSite.new
    ps.site_id = site_id
    ps.page_id = page_id
    ps.save
  end
  
end
