class Photo < Asset

  #has_and_belongs_to_many :posts  
  
  has_attached_file :data, 
    :styles => { :content => '600x600', :medium => "200x200", :thumb => "100x100" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :bucket =>   S3_BUCKET,
    :path => "photos/" <<
                ":attachment/:id_partition/" <<
                ":basename_:style.:extension",
    :url =>  "photos/:attachment/:id_partition/" <<
                ":basename_:style.:extension"

  unless Rails.env.development?
    validates_attachment_content_type :data,
      :content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png',
                          'image/x-png', 'image/jpg'],
      :message      => I18n.t('errors.asset.image.format')

      validates_attachment_size :data, :in => 0..3.megabytes, :message      => I18n.t('errors.asset.image.size')
  end
  
  named_scope :apply_filter_to_list, lambda{ |filter_name|
    f = FILTERS[filter_name] || FILTERS['recency']
    options = {}
    options[:order] = f[:ordering].gsub('TABLE_NAME', 'assets') if f[:ordering]
    options[:conditions] = f[:conditions].gsub('TABLE_NAME', 'assets') if f[:conditions]
    options
  }
  
  def self.image_file_exists?(file_name)
    find(:last, :conditions=>["data_file_name=?", file_name])
  end
  
  def create_photo_from_url(url, user_id)
    self.type = 'Photo'
    self.user_id = user_id
    image = download_remote_image(url)
    self.data = image
    image ? self.save : false
  end
  
  def download_remote_image(image_url)
    io = open(URI.parse(image_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    nil
  end
  
  def permalink
    photo_path(self, {:only_path => false})
  end

end
