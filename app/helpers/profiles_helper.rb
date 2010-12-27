module ProfilesHelper
  
  def show_replies
    params[:controller]!='comments' && params[:controller]!='search' && params[:controller]!='profiles'
  end

end
