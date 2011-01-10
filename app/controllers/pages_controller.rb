class PagesController < ApplicationController
  resources_controller_for :pages
  
  before_filter :clear_home_page_settings, :only => [:create, :update]
  before_filter :is_admin
  
  def show
    @page = find_resource
    @header[:title] << t("common.page.display").capitalize
    @header[:title] << @page.title
    @header[:description] = @page.excerpt?
  end
  
  def index
    @header[:title] << t("common.page.display").capitalize
    @pages = Page.get_pages(params[:page], logged_in_and_admin)
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
  
  def set_as_home_page
    reset_home_page
    @page = find_resource
    @page.is_home_page = true
    @page.save
    flash[:notice] = "You have set this post to be the home page!"
    redirect_to "/"
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
  
  def set_order
    Page.update_all({:position=>100000})
    position = 1
    params[:positions].each do |page|
      p = Page.find_by_id(page)
      p.update_attributes({:position => position}) if p
      position += 1
    end
    render :text => "ok"
  end
  
  protected
  
  def clear_home_page_settings
     reset_home_page if params[:page] && params[:page][:is_home_page]
  end
  
end
