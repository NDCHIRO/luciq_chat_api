class ApplicationsController < ApplicationController
  before_action :set_application, except: [:create]


  # POST /applications
  def create
    app = Application.new(application_params)

    if app.save
      render json: { name: app.name, token: app.token }, status: :created
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /applications/:token
  def show
    render json: {
      name: @application.name,
      token: @application.token,
      chats_count: @application.chats_count,
      created_at: @application.created_at
    }
  end

  # PATCH /applications/:token
  def update
    if @application.update(application_params)
      render json: { name: @application.name, token: @application.token }, status: :ok
    else
      render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def message_count
    # DB: sum the counter_cache on chats
    db_total = @application.chats.sum(:messages_count)

    # Redis: optional per-chat counters (use if higher than DB)
    redis_total = 0
    @application.chats.find_each do |chat|
      redis_total += REDIS.get("chat:#{chat.id}:messages_count").to_i
    end

    total = [db_total, redis_total].max
    render json: { application_token: @application.token, messages_count: total }
  end

  private

  def set_application
      @application = Application.find_by!(token: params[:application_token] || params[:token])
  end

  def application_params
    params.require(:application).permit(:name)
  end
end