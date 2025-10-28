class MessagesController < ApplicationController
  before_action :set_application
  before_action :set_chat
  before_action :set_message, only: [:show]

  # GET /applications/:token/chats/:number/messages
  def index
    messages = @chat.messages.select(:number, :body, :created_at)

    render json: messages.as_json(only: [:number, :body, :created_at])
  end

  # GET /applications/:token/chats/:number/messages/:number
  def show
    render json: {
      number: @message.number,
      body: @message.body,
      created_at: @message.created_at
    }
  end

  # POST /applications/:token/chats/:number/messages
  def create
    message = @chat.messages.build(message_params)
    # number will be auto-assigned by Message model

    if message.save
      render json: { number: message.number, body: message.body }, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:application_token] || params[:token])
  end

  def set_chat
    @chat = @application.chats.find_by!(number: params[:chat_number] || params[:number])
  end

  def set_message
    @message = @chat.messages.find_by!(number: params[:number])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
