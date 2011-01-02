class Account::SettingsController < ApplicationController
  resources_controller_for :settings, :singleton => true, :class=>"Setting"
  
  before_filter :login_required
  
  def index
    @settings = find_resource 
    unless @settings
      @settings = Setting.new
      @settings.user_id = @current_user.id
      @settings.save
    end
  end
  
  def update
    @settings = find_resource
    params[:setting][:about_me] = params[:settings][:about_me].sanitize(:tags => %w(a u i em b strong))
    @settings.update_attributes!(params[:setting])
    if resource_saved?
      @profile.update_attributes({:password => @profile.password, :confirm_password => @profile.password, :updated_at => Time.now})
      flash[:notice] = 'Your settings have been saved.'
      redirect_to account_settings_path
    else
      render :action => 'index'
    end
  end
  
  def find_resource
    @profile = Profile.find_by_id(@current_user.id)
    @profile.settings
  end
  
end