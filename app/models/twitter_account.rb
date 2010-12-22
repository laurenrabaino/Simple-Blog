class TwitterAccount < ActiveRecord::Base
  belongs_to :user

  def update_status(status="")
    begin
      client = TwitterOAuth::Client.new( :consumer_key => SETTINGS[:twitter][:key], :consumer_secret => SETTINGS[:twitter][:secret], :token => self.token, :secret => self.secret )
      client.update(status) if client && client.authorized? && !status.blank?
    rescue
    end
  end
  
end