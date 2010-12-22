class TagsController < ApplicationController

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
