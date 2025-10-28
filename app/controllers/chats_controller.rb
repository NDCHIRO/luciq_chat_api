class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show]

  # GET /applications/:token/chats
  def index
    chats = @application.chats.select(:number, :messages_count, :created_at)

    render json: chats.as_json(
      only: [:number, :messages_count, :created_at]
    )
  end

  # GET /applications/:token/chats/:number
  def show
    render json: {
      number: @chat.number,
      messages_count: @chat.messages_count,
      created_at: @chat.created_at
    }
  end

  # POST /applications/:token/chats
  def create
    chat = @application.chats.build
    # number will be auto-assigned by Chat model before_validation

    if chat.save
      render json: { number: chat.number }, status: :created
    else
      render json: { errors: chat.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:application_token] || params[:token])
  end

  def set_chat
    @chat = @application.chats.find_by!(number: params[:number])
  end
end
