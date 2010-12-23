class TagsController < ApplicationController

  def show
    
    @tab = params[:tab] ? params[:tab] : "posts"
    @tag = URI.decode(params[:id]) if params[:id]
    @tag = URI.decode(params[:tag_id]) if params[:tag_id]
    @page = params[:page] ? params[:page] : 1
    
    @header[:title] << t("common.tag.display").pluralize.capitalize
    @header[:title] << @tag
    
    if @tab == "posts"
      Post.per_page = 10
      @posts = Post.tagged_with(@tag, @page)
      @header[:title] << t("common.blog.display").pluralize.capitalize
    elsif @tab == "pages" 
      Page.per_page = 10
      @pages = Page.tagged_with(@tag, @page)
      @header[:title] << t("common.page.display").pluralize.capitalize
    else
      Post.per_page = 10
      @posts = Post.tagged_with(@tag, @page)
      @header[:title] << t("common.blog.display").pluralize.capitalize
    end
    
  end

  def suggest
    arr = []
    
    # check for existing tags
    unless params[:existing_tags]
      existing_tags = [] 
    else
      existing_tags_arr = params[:existing_tags].split(",")
      existing_tags_arr.map{ |a| arr << a.strip  }
    end
    
    # get tags from OC
    begin
      e = Entity.new
      arr = arr.concat(e.tags?(params[:text]))
    rescue
    end
    
    # render response
    render :text => arr.uniq.join(", ")
  end

end
