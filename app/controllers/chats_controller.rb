class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show, :message_count]

  # GET /applications/:token/chats
  def index
    chats = @application.chats.select(:number, :messages_count, :created_at)
    render json: chats
  end

  # GET /applications/:token/chats/:chat_number
  def show
    render json: {
      chat_number: @chat.number,
      messages_count: @chat.messages_count,
      created_at: @chat.created_at
    }
  end

  # POST /applications/:token/chats
  def create
    chat = @application.chats.build # number auto-generated
    if chat.save
      render json: { chat_number: chat.number }, status: :created
    else
      render json: { errors: chat.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def message_count
    redis_count = REDIS.get("chat:#{@chat.id}:messages_count").to_i
    db_count    = @chat.messages_count
    total = [redis_count, db_count].max

    render json: { chat_number: @chat.number, messages_count: total }
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
end
