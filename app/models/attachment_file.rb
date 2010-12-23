class AttachmentFile < Asset
  
  has_and_belongs_to_many :posts
  
  belongs_to :profile, :foreign_key => "user_id", :class_name=>"User", :touch => true
  
  has_attached_file :data, 
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :bucket =>   S3_BUCKET,
    :path => "files/" <<
                ":attachment/:id_partition/" <<
                ":basename.:extension",
    :url =>  "files/:attachment/:id_partition/" <<
                ":basename.:extension"

  validates_attachment_size :data, :in => 0..3.megabytes, :message      => I18n.t('errors.asset.file.size')
  
end
