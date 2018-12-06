class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = Message.all.page(params[:page])
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      redirect_to @message
    else
      render :new
    end
  end

  def edit
    @message = Message.find(params[:id])
    authorize(@message)
  end

  def update
    @message = Message.find(params[:id])
    authorize(@message)
    if @message.update(message_params)
      redirect_to @message
    else
      render :edit
    end
  end

  def show
    @message = Message.find(params[:id])
  end

  def destroy
    @message = Message.find(params[:id])
    authorize(@message)
    @message.destroy
    redirect_to messages_path
  end

  private

  def message_params
    params.require(:message).permit(:content, :picture).merge(user_id: current_user.id)
  end
end
