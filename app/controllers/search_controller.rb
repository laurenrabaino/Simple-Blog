class SearchController < ApplicationController
  
  def index
    
    if params[:q]
      redirect_to "/search/#{URI.encode(params[:q])}"
      return
    end
    
    @tab = params[:tab] ? params[:tab] : "posts"
    @search_term = URI.encode(params[:search_term] || params[:q] || "")
    @page = params[:page] ? params[:page] : 1
    
    if @tab == "posts"
      Post.per_page = 10
      @posts = Post.get_search(@search_term, @page, logged_in_and_admin)
    elsif @tab == "pages" 
      Page.per_page = 10
      @pages = Page.get_search(@search_term, @page, logged_in_and_admin)
    elsif @tab == "comments" 
      Comment.per_page = 10
      @comments = Comment.get_search(@search_term, @page, logged_in_and_admin)
    else
      Post.per_page = 10
      @posts = Post.get_search(@search_term, @page, logged_in_and_admin)
    end 
  end
  
end
