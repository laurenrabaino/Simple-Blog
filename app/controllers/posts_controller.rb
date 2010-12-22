class PostsController < ApplicationController

  resources_controller_for :post
  
  def show
    begin
      @post = find_resource
      @header[:title] << t("common.blog.display").capitalize
      @header[:title] << @post.title
      @header[:description] = @post.excerpt?
      @header[:keywords] = @post.tag_list
    rescue
      flash[:notice] = "The post has been deleted and cannot be accessed any longer."
      redirect_to "/"
      return
    end
  end
  
  def index
    @header[:title] << t("common.blog.display").capitalize
    
    Post.per_page = 10
    @posts = Post.get_posts_index(params[:page], @filter, logged_in_and_admin)
    
    respond_to do |format|
      format.html do
      end
      format.rss do
        render :layout => false
      end
    end
  end
  
  def create
    params[:post][:user_id] = @current_user.id                                 # make sure to set the user_id if the user is set
    params[:post][:status] = 1
    params[:post][:body] = params[:post][:body].sanitize if params[:post] && params[:post][:body]
    params[:post][:excerpt] = params[:post][:excerpt].sanitize if params[:post] && params[:post][:excerpt]
    
    @post = Post.new(params[:post])
    
    if @post.save
      redirect_to post_path(@post)
    else
      render :action => 'new'
    end
  end
  
  def tweet
    post = find_resource
    update_twitter("Post", post)
    redirect_to :back
  end
  
  def facebook
    post = find_resource
    update_facebook("Post", post)
    redirect_to :back
  end
  
  def publish
    @post = find_resource
    @post.status = 1
    @post.save
    flash[:notice] = "You have published this post!"
    redirect_to :back
  end
  
  def unpublish
    @post = find_resource
    @post.status = 0
    @post.save
    flash[:notice] = "You have unpublished this post!"
    redirect_to :back
  end
  
  def favorite
    @post = find_resource
    favorite = @post.favorites.create({ :ip => request.remote_ip, :user_id => session[:user_id] })
    @post.favorited = @post.favorited ? (@post.favorited.to_i + 1) : 1
    @post.save
    redirect_to :back
  end
  
  def featured
    @post = find_resource
    favorite = @post.features.create({ :ip => request.remote_ip, :user_id => session[:user_id] }) unless @post.features.find_by_user_id(@current_user.id)
    @post.featured_at = Time.now
    @post.featured = true
    @post.save
    redirect_to :back
  end
  
end
