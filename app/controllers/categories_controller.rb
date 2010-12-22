class CategoriesController < ApplicationController
  
  resources_controller_for :categories
  
  def index
    @header[:title] << t("common.category.display").capitalize.pluralize
    @categories = Category.paginate(:page => params[:page])
    
    respond_to do |format|
      format.html do
      end
      format.rss do
        render :layout => false
      end
    end
  end
  
  def create
    @category = Category.new(params[:category])
    if @category.save
      redirect_to category_path(@category)
    else
      render :action => 'new'
    end
  end
  
  def show_category
    @category = Category.get_category(params[:seo_name])
    if @category
      @tab = params[:tab] ? params[:tab] : "posts"
      @page = params[:page] ? params[:page] : 1
      
      @header[:title] << t("common.category.display").capitalize
      @header[:title] << @category.name
      
      Post.per_page = 10
      @posts = @category.get_posts(@page, is_admin)
      @header[:title] << t("form.article").capitalize.pluralize
    else
      redirect_to "/"
      return
    end
  end
  
end
