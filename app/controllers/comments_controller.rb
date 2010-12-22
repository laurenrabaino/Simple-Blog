class CommentsController < ApplicationController
  resources_controller_for :comments

  before_filter :sanitize_params, :only => [ :create, :edit ]

  def index
    @filter = 'all'
    @comments = Comment.paginate(:page => params[:page], :order=>'created_at desc')
  end

  def ham
    @filter = 'ham'
    @comments = Comment.just_ham.paginate(:page => params[:page], :order=>'created_at desc')
    render :template => "comments/index"
  end
  
  def spam
    @filter = 'spam'
    @comments = Comment.just_spam.paginate(:page => params[:page], :order=>'created_at desc')
    render :template => "comments/index"
  end
  
  def delete_spam
    Comment.delete_all("spam=1")
    redirect_to :back
  end
  
  def edit
    @comment = find_resource
    if !logged_in_and_admin && (@comment.profile!=@current_user || @comment.created_at<15.minutes.ago)
      head :bad_request
    end
  end

  def create
    @comment = Comment.new(params[:comment])
    @comment.env = request.env
    @comment.ip = request.remote_ip

    if (verify_recaptcha(:model => @comment,:message => I18n.t('errors.bad_captcha')) || @current_user) && @comment.save
      if @comment.spam
        count_comments_spaminess = Comment.count(:conditions => ["spaminess > 0.75 && ip = ?", request.remote_ip])
        count_comments_spam = Comment.count(:conditions => ["spam = 1 && ip = ?", request.remote_ip])
        BlockedIp.create({ :ip => request.remote_ip }) if @comment.spaminess >= 0.90 || (count_comments_spaminess.to_i + count_comments_spam.to_i) > 2
        flash[:error] = I18n.t("notice.comment.create.oops")
        redirect_to enclosing_resource
      else
        flash[:notice] = I18n.t("notice.comment.create.success")
        redirect_to :back
      end
    else
      redirect_to :back
    end
  end
  
  def update
    @comment = find_resource
    @comment.update_attributes(params[:comment])

    if @comment.save
      if @comment.spam
        count_comments_spaminess = Comment.count(:conditions => ["spaminess > 0.75 && ip = ?", request.remote_ip])
        count_comments_spam = Comment.count(:conditions => ["spam = 1 && ip = ?", request.remote_ip])
        BlockedIp.create({ :ip => request.remote_ip }) if @comment.spaminess >= 0.90 || (count_comments_spaminess.to_i + count_comments_spam.to_i) > 2
        flash[:error] = I18n.t("form.comment.notice.edit.oops")
        redirect_to @comment.commentable.permalink
      else
        flash[:notice] = I18n.t("form.comment.notice.edit.oops")
        redirect_to @comment.commentable.permalink
      end
    else
      redirect_to @comment.commentable.permalink
    end
  end

  def report_as_spam
    comment = find_resource
    comment.report_as_spam
    redirect_to :back
  end

  def report_as_ham
    comment = find_resource
    comment.report_as_ham
    comment.new_comment_published
    redirect_to :back
  end
  
  protected
  
  def sanitize_params
    params[:comment][:body] = params[:comment][:body].sanitize if params[:comment] && params[:comment][:body]
  end
  
end
