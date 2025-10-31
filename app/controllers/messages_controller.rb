class MessagesController < ApplicationController
  before_action :set_application
  before_action :set_chat
  before_action :set_message, only: [:show]

  def index
    messages = @chat.messages.select(:number, :body, :created_at)
    render json: messages
  end

  def show
    render json: {
      message_number: @message.number,
      body: @message.body,
      created_at: @message.created_at
    }
  end

  def create
    redis_key = "chat:#{@chat.id}:message_number"
    message_number = REDIS.incr(redis_key)

    message = @chat.messages.build(message_params.merge(number: message_number))

    if message.save
      REDIS.incr("chat:#{@chat.id}:messages_count")
      render json: { message_number: message.number, body: message.body }, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def search
    term = "%#{params[:q]}%"
    results = @chat.messages.where("body LIKE ?", term)
    render json: results
  end

  private

  def set_application
    token = params[:application_token] || params[:token] || request.path_parameters[:application_token]
    @application = Application.find_by!(token: token)
  end

  def set_chat
    number = params[:chat_number] || request.path_parameters[:chat_number] || params[:chat_chat_number]
    @chat = @application.chats.find_by!(number: number)
  end

  def set_message
    @message = @chat.messages.find_by!(number: params[:message_number])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
