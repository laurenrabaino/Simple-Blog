class Account::NotificationSettingsController < ApplicationController
  
  before_filter :login_required
  
  def show
    @notify = {}
    @notify[:twitter] = @current_user.get_setting?('Twitter')
    @notify[:facebook] = @current_user.get_setting?('Facebook')
  end
  
  def update
    twitter = params[:notify] ? params[:notify][:twitter].to_i : 0
    facebook = params[:notify] ? params[:notify][:facebook].to_i : 0
    NotifySetting.update_all("value=#{twitter}", "user_id=#{@current_user.id} and notify_type='Twitter'")
    NotifySetting.update_all("value=#{facebook}", "user_id=#{@current_user.id} and notify_type='Facebook'")
    redirect_to account_notification_setting_path
  end
  
end
