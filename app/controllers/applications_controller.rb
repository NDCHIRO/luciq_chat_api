class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :update]

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

  private

  def set_application
    @application = Application.find_by!(token: params[:token])
  end

  def application_params
    params.require(:application).permit(:name)
  end
end