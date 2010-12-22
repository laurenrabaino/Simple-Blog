class Favorite < ActiveRecord::Base
  belongs_to :favoriteable, :polymorphic => true
  belongs_to :user
  belongs_to :profile, :foreign_key => :user_id
end
