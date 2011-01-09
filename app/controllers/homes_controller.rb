class HomesController < ApplicationController
  
  def index
    get_home_page
    render :template => get_home_page_template
  end
  
  private
  
  # define the home page variables...
  def get_home_page
    @post = @home_post      # loaded on each load to know if the blog link should be shown or not
    @page = @home_page      # loaded on each load to know if the blog link should be shown or not

    unless @post || @page
      Post.per_page = 10
      @posts = Post.get_posts(params[:page], @filter, logged_in_and_admin) 
      @tags = Post.get_tags(logged_in_and_admin)
    end
  end
  
  # get the proper template based on the home page variables...
  def get_home_page_template
    return "/posts/show" if @post
    return "/pages/show" if @page
    "/homes/index"
  end
  
end
