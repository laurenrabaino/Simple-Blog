class Notifier < ActionMailer::Base
  
  include Utils
  include ActionController::UrlWriter
  default_url_options[:host] = SETTINGS[:site][:host]

  def email(to_email, subject, message, mail_type="text/html")
    @subject    = subject
    @body       = {:message => message.strip}
    @recipients = to_email
    @from       = SETTINGS[:site][:noreply]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def account_confirmation(to_email, options, mail_type="text/html")
    @subject    = options[:locale]=="es" ? "¡Bienvenido a #{SETTINGS[:site][:name]}!" : "Welcome to #{SETTINGS[:site][:name]}!"
    @body       = options
    @recipients = to_email
    @from       = SETTINGS[:site][:noreply]
    @bcc        = SETTINGS[:site][:email]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_post_update(emails, options, mail_type="text/html")
    @subject    = "Nuevo Entrada En El Blog :: #{SETTINGS[:site][:name]}"
    @body       = options
    @recipients = SETTINGS[:site][:email]
    @from       = SETTINGS[:site][:noreply]
    @bcc        = emails.join(',')
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_user(emails, options, mail_type="text/html")
    @subject    = "Nuevo Miembro :: #{SETTINGS[:site][:name]}"
    @body       = options
    @recipients = SETTINGS[:site][:email]
    @from       = SETTINGS[:site][:noreply]
    @bcc        = emails.join(',')
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_password(to_email, options, mail_type="text/html")
    @subject    = options[:locale]=="es" ? "#{SETTINGS[:site][:name]}: Su contraseña temporal" : "#{SETTINGS[:site][:name]}: Your temporary password"
    @body       = options
    @recipients = to_email
    @from       = SETTINGS[:site][:noreply]
    @bcc        = SETTINGS[:site][:email]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_comment_published(options, mail_type="text/html")
    @subject    = "#{SETTINGS[:site][:name]}: #{I18n.t("comment.new").gsub("USERNAME", options[:comment].author_name).gsub("TYPE", options[:commentable][:type])}"
    @body       = options
    @recipients = "#{options[:commentable][:author]} <#{options[:commentable][:email]}>"
    @from       = SETTINGS[:site][:noreply]
    @bcc        = SETTINGS[:site][:email]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_comment_reply(options, mail_type="text/html")
    @subject    = "#{SETTINGS[:site][:name]}: #{I18n.t("comment.new_reply").gsub("USERNAME", options[:comment].author_name).gsub("TYPE", options[:commentable][:type])}"
    @body       = options
    @recipients = "#{options[:commentable][:author]} <#{options[:commentable][:email]}>"
    @from       = SETTINGS[:site][:noreply]
    @bcc        = SETTINGS[:site][:email]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
end
