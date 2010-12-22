class Feature < ActiveRecord::Base
  belongs_to :featurable, :polymorphic => true
  belongs_to :user
  belongs_to :profile, :foreign_key => :user_id
end
