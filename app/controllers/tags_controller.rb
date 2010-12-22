class TagsController < ApplicationController

  def show
    Post.per_page = 10
    posts_search_results = Post.find_tagged_with(URI.decode(params[:id]))
    @posts = posts_search_results.paginate({:page => @page, :per_page=>10})
    
    @header[:title] << t("common.tag.display").pluralize.capitalize
    @header[:title] << params[:id]
    @header[:title] << t("common.blog.display").pluralize.capitalize
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
