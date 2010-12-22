class Account::FacebookAccountsController < ApplicationController
  
  resources_controller_for :facebook_account
  
  before_filter :login_required, :except => [:connect, :callback]
  
  include OauthConnect
  
  def show
    unless @current_user.has_facebook_oauth?
      @link = check_credentials
    end
  end
  
  def connect
    session[:fbc] = true
    redirect_to check_credentials
    return
  end

  def callback
    
    user_agent = request ? request.user_agent : nil
    if user_agent =~ BOT_FILTER
      head :bad_request
      return
    end
    
    access_token = fb_access_token(params[:code])
    
    unless access_token
      flash[:notice] = t("account.service.oops").gsub('EXTERNAL_SITE', 'Facebook').gsub('SITE_NAME', SETTINGS[:site][:name])
	    redirect_to "/connect"
      return
	  else
      begin 
        fb_user = JSON.parse(access_token.get('/me'))
      rescue
        fb_user = nil
      end
      session[:fb_session] = fb_user ? params[:code] : nil
      if fb_user
        existing_fb_account = FacebookAccount.find_by_fb_user_id(fb_user["id"].to_i)               # check for existing facebook account...
        if @current_user && (!existing_fb_account || existing_fb_account.user_id == @current_user.id) 
          unless @current_user.has_facebook_oauth?  
            facebook_account = FacebookAccount.create({ :user_id => @current_user.id, :fb_user_id => fb_user["id"].to_i, :code => params[:code] }) 
            flash[:notice] = t("account.service.linked").gsub('EXTERNAL_SITE', 'Facebook').gsub('SITE_NAME', SETTINGS[:site][:name])
          end
        else
          flash[:notice] = t("account.service.already_linked").gsub('EXTERNAL_SITE', 'Facebook').gsub('SITE_NAME', SETTINGS[:site][:name])
        end
      else
        flash[:notice] = t("account.service.oops").gsub('EXTERNAL_SITE', 'Facebook').gsub('SITE_NAME', SETTINGS[:site][:name])
        redirect_to "/connect"
        return
      end
    end
    
    # handle the different cases of redirects...
    unless @current_user                                                    # login flow...
      flash[:notice] = nil
      if existing_fb_account  
        profile = Profile.find_by_id(existing_fb_account.user_id)
        if profile.status.to_i > 1                                          # already activated user, login and proceed...                    
          session[:user_id] = profile.id
          redirect_to profile_path(profile)
          return
        else                                                                # set the right user...
          session[:fbc] = existing_fb_account.user_id
          session[:fbu] = fb_user["id"].to_i
        end
      else
        email = fb_user["email"] || ""
        profile = Profile.find_by_email(email)                              # check for existing users with that email...
        if profile                                                          # existing user with email matching, attach the credentials to it...
          facebook_account = FacebookAccount.create({ :user_id => profile.id, :fb_user_id => fb_user["id"].to_i, :code => params[:code] }) 
          flash[:notice] = t("account.service.linked").gsub('EXTERNAL_SITE', 'Facebook').gsub('SITE_NAME', SETTINGS[:site][:name])
          session[:user_id] = profile.id
          redirect_to profile_path(profile)
          return
        else                                                                # no matching user, create dummy user...
          profile = create_dummy_profile(email)
          session[:fbc] = profile.id
          session[:fbu] = fb_user["id"].to_i
        end
      end
      redirect_to "/connect"
      return
    else                                                                    # logged in user connecting through their Facebook acount page...
      redirect_to account_facebook_account_path                             
      return
    end
    
  end
  
  protected
  
  def check_credentials    
    facebook_oauth_client = get_facebook_oauth_client
    return facebook_oauth_client.web_server.authorize_url(
			:redirect_uri => SETTINGS[:facebook][:callback_url],
			:display => "page",
			:scope => "publish_stream,offline_access,email"
		)
  end
  
  def create_dummy_profile(email)
    password = "changeme"
    return Profile.create({:user_name => "", :email => email, :password => password, :confirm_password => password, :status => 0, :send_confirmation => false})
  end

end