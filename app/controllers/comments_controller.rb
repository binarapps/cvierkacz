class CommentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @comment = Comment.find(params[:id])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      redirect_to @comment.message
    else
      @message = Message.find(comment_params[:message_id])
      render 'messages/show'
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      redirect_to @comment
    else
      render :edit
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to message_path(@comment.message)
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :author, :message_id)
  end
end
