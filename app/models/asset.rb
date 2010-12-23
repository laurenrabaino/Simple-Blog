class Asset < ActiveRecord::Base
  
  include Utils
  include ActionController::UrlWriter
  default_url_options[:host] = SETTINGS[:site][:host]
  
  cattr_accessor :per_page
  @@per_page = 36
  
  belongs_to :profile, :foreign_key => "user_id", :class_name=>"User", :touch => true
  belongs_to :assetable, :polymorphic => true
  
  has_many :comments, :as => :commentable, :dependent => :destroy, :conditions => "comments.parent_id is null"
  has_many :favorites, :as => :favoriteable, :dependent => :destroy
  has_many :clickstreams, :as => :clickstreamable, :dependent => :destroy
  has_many :features, :as => :featurable, :dependent => :destroy

  def excerpt?
    return excerpt unless excerpt.blank?
    if body
      short_body = body.length>256 ? body[0..253].gsub(/\w+$/, '')+"..." : body
    else
      short_body = ""
    end
    
    return short_body
  end

  def url(*args)
    data.url(*args)
  end

  def filename
    data_file_name
  end

  def content_type
    data_content_type
  end

  def size
    data_file_size
  end

  def to_xml(options = {})
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

    xml.tag!(self.type.to_s.downcase) do
      xml.filename{ xml.cdata!(self.filename) }
      xml.size self.size
      xml.path{ xml.cdata!(self.url) }

      xml.styles do
        self.styles.each do |style|
          xml.tag!(t.style, self.url(style))
        end
      end unless self.styles.empty?
    end
  end
  
  def to_s
    title
  end
  
  def to_param
    begin 
      "#{id}-#{to_s.parameterize}"
    rescue
      "#{id}"
    end
  end
  
end
