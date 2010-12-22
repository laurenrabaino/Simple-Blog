class Setting < ActiveRecord::Base

  extend ActiveSupport::Memoizable
  include ActiveSupport::Memoizable
  
  belongs_to :profile, :foreign_key => :user_id

end