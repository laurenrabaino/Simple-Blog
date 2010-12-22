class Admin::IncomingsController < ApplicationController
  
  #before_filter :admin_required
  #skip_before_filter :verify_authenticity_token  

  # Being invoked as a POST from the mail_poller
  def create
    mail = TMail::Mail.parse(params[:email])
    
    # parse the email...
    arguments = {}
    email = mail.from.first.to_s
    to_emails = mail.to
    arguments[:title] = mail.subject.to_s
    arguments[:excerpt] = ""
    
    if !to_emails || to_emails.empty?
      head :bad_request
      return
    end
    
    # handle the mail body
    mail_body = mail.body_html || mail.body_plain || ""
    mail_body = mail_body.gsub("\n\n", "<br /><br />") if mail.body_plain
    mail_body.gsub!(/<!DOCTYPE [^>]*>/, '') if mail_body
    mail_body.strip! if mail_body
    arguments[:body] = mail_body.to_s.sanitize
    
    #check if it is a known user...
    user = Profile.find_by_email(email)
    if user
      arguments[:user_id] = user.id
      arguments[:status] = 1
    else                                                        # not a known user so skipping...
      render :text => 'Not a known user...'
      return
    end
    
    # save the post
    post = Post.new(arguments)
    
    if Entity.active?
      begin
        e = Entity.new
        post.tag_list = e.tags?(post.body).uniq.join(", ")
      rescue
      end
    end
    
    post.save
    
    render :text => "success"
  end
    
end