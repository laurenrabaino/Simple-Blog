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
    @subject    = I18n.t("notifier.account_confirmation.subject").gsub('SITE_NAME', SETTINGS[:site][:name])
    @body       = options
    @recipients = to_email
    @from       = SETTINGS[:site][:noreply]
    @bcc        = SETTINGS[:site][:email]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_post_update(emails, options, mail_type="text/html")
    @subject    = I18n.t("notifier.new_post_update.subject").gsub('SITE_NAME',SETTINGS[:site][:name])
    @body       = options
    @recipients = SETTINGS[:site][:email]
    @from       = SETTINGS[:site][:noreply]
    @bcc        = emails.join(',')
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_user(emails, options, mail_type="text/html")
    @subject    = I18n.t("notifier.new_user.subject").gsub('SITE_NAME',SETTINGS[:site][:name])
    @body       = options
    @recipients = SETTINGS[:site][:email]
    @from       = SETTINGS[:site][:noreply]
    @bcc        = emails.join(',')
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_password(to_email, options, mail_type="text/html")
    @subject    = I18n.t("notifier.new_password.subject").gsub('SITE_NAME', SETTINGS[:site][:name] )
    @body       = options
    @recipients = to_email
    @from       = SETTINGS[:site][:noreply]
    @bcc        = SETTINGS[:site][:email]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_comment_published(options, mail_type="text/html")
    @subject    = "#{SETTINGS[:site][:name]}: #{I18n.t("notifier.comment.new").gsub("USERNAME", options[:comment].author_name).gsub("TYPE", options[:commentable][:type])}"
    @body       = options
    @recipients = "#{options[:commentable][:author]} <#{options[:commentable][:email]}>"
    @from       = SETTINGS[:site][:noreply]
    @bcc        = SETTINGS[:site][:email]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
  def new_comment_reply(options, mail_type="text/html")
    @subject    = "#{SETTINGS[:site][:name]}: #{I18n.t("notifier.comment.new_reply").gsub("USERNAME", options[:comment].author_name).gsub("TYPE", options[:commentable][:type])}"
    @body       = options
    @recipients = "#{options[:commentable][:author]} <#{options[:commentable][:email]}>"
    @from       = SETTINGS[:site][:noreply]
    @bcc        = SETTINGS[:site][:email]
    @sent_on    = Time.now
    @headers    = {}
    content_type mail_type      
  end
  
end
