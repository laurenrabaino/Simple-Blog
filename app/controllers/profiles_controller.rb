class ProfilesController < ApplicationController
  resources_controller_for :profile
  
  before_filter :check_access
  
  def index
    if @current_user && @current_user.is_admin?
      @profiles = Profile.paginate(:page => params[:page], :order => "users.user_name asc")
    else
      redirect_to "/"
      return
    end
  end
  
  def show
    id = params[:profile_id] || params[:id]
    @profile = find_resource(id)
    
    @tab = params[:tab] ? params[:tab] : "posts"
    @page = params[:page] ? params[:page] : 1

    # add in events, jobs, posts, friends, followers...
    if @tab == 'comments'
      Comment.per_page = 10
      @comments = @profile.get_comments(@page, is_admin)
    elsif @tab == 'posts'
      Post.per_page = 10
      @posts = @profile.get_posts(@page)
    end
    
  end
  
  def edit
    @profile = find_resource
    @profile.confirm_password = @profile.password
  end
  
  def create
    @profile = Profile.new(params[:profile])
    @profile.locale = get_locale
      
    if verify_recaptcha(:model=>@profile, :message => I18n.t('errors.profile.bad_captcha')) && @profile.save
      
      unless logged_in_and_admin
        session[:user_id] = @profile.id 
        set_locale
      end
      
      redirect_to profile_path(@profile)
    else
      render :action => 'new'
    end
  end
  
  def login
    unless params[:user_name].blank? || params[:password].blank?
      @profile = Profile.find(:first, :conditions=>["user_name=? and password=?", params[:user_name], params[:password]])
      if @profile
        session[:user_id] = @profile.id
        set_locale
        redirect_to profile_path(@profile)
        return
      else
        @profile = Profile.find(:first, :conditions=>["user_name=? and temporary_password=?", params[:user_name], params[:password]])
        if @profile
          session[:user_id] = @profile.id
          session[:temp] = @profile.temporary_password_hash
          
          reset_password_link = "/reset_password/#{@profile.temporary_password_hash}"
          @profile.generate_temporary_password
          redirect_to reset_password_link
          return
        else
          @error_text = I18n.t("errors.profile.badlogin")
        end
      end
    else
        @error_text = I18n.t("errors.profile.badlogin") if params[:user_name] || params[:password]
    end
  end
  
  def recover
    if params[:q]
      @profile = Profile.find(:first, :conditions=>["user_name=?", params[:q]])
      @profile = Profile.find(:first, :conditions=>["email=?", params[:q]]) unless @profile
      if @profile
        @profile.locale = get_locale
        @profile.generate_temporary_password(true)
        flash[:notice] = I18n.t("account.reset_password_instructions")
        redirect_to "/"
        return
      else
        @error_text = I18n.t("errors.profile.forgot")
      end
    else
      @error_text = I18n.t("errors.profile.forgot") if params[:q]
    end
  end
  
  def send_pm
    @profile = find_resource
    if @current_user && @profile
      redirect_to new_profile_pm_path @current_user, :r => @profile.id
      return
    else
      head :bad_request
      return
    end
  end
  
  def reset_password
    if !params[:temp] || !session[:temp] || (params[:temp] != session[:temp] && @current_user)
      redirect_to "/"
      return
    end
    
    if params[:password] && params[:confirm_password] && !params[:password].blank? && params[:password]==params[:confirm_password]
      p = Profile.find_by_id(@current_user.id)
      p.update_attributes({:password => params[:password], :confirm_password => params[:confirm_password]})
      session[:temp] = nil
      redirect_to "/"
      return
    else
      @error_text = I18n.t("errors.profile.passwordsdonotmatch") if params[:password] && params[:confirm_password]
    end
  end
  
  def connect
    unless session[:fbc]
      head :bad_request
      return
    end
    
    @profile = Profile.find_by_id(session[:fbc])                        # get the profile
    
    if params[:profile]
      params[:profile][:confirm_password] = @profile.password
      @profile.update_attributes(params[:profile])
      @profile.locale = get_locale

      if @profile.save
        
        #send updates...
        @profile.update_attributes(:status => 2)
        @profile.send_confirmations

        session[:fbc] = nil
        session[:fbu] = nil
        session[:user_id] = @profile.id unless logged_in_and_admin
        set_locale
        redirect_to profile_path(@profile)
        return
      end
    end
    
  end
  
  def logout
    reset_session
    redirect_to "/"
    return
  end
  
  def favorite
    @profile = find_resource
    favorite = @profile.favorites.create({ :ip => request.remote_ip, :user_id => session[:user_id] })
    @profile.favorited = @profile.favorited ? (@profile.favorited.to_i + 1) : 1
    @profile.confirm_password = @profile.password
    @profile.updated_at = Time.now
    @profile.save
    redirect_to :back
  end
  
  def featured
    @profile = find_resource
    favorite = @profile.features.create({ :ip => request.remote_ip, :user_id => session[:user_id] }) unless @profile.features.find_by_user_id(@current_user.id)
    @profile.featured_at = Time.now
    @profile.featured = true
    @profile.confirm_password = @profile.password
    @profile.updated_at = Time.now
    @profile.save
    redirect_to :back
  end
  
  private
  
  def check_access
    @current_user==@profile || (@current_user && @current_user.is_admin?)
  end
  
end
