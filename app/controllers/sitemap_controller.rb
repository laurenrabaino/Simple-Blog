class SitemapController < ApplicationController
  
  def index
    @url_set = {:xmlns=>"http://www.sitemaps.org/schemas/sitemap/0.9"}
    @news ||= params[:news]
    @url_set["xmlns:n".to_sym] = "http://www.google.com/schemas/sitemap-news/0.9" if @news
    @prefix_template = @news ? "news_" : ""
    initialize_sitemap
  end
  
  def sitemap_index
  end
  
  protected

   def initialize_sitemap
     sitemap_types = {'posts'=>true}
     unless sitemap_types[params[:type]]
       #redirect to landing page or better present 404
       redirect_to '/'
       return
     end 

     @type = params[:type]
     case @type
       when 'posts'
         @posts = Post.all
     end

     render :layout=>false
   end
   
end
