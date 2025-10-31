class UpdateMessageCountJob < ApplicationJob
  queue_as :default

  def perform(application_token)
    application = Application.find_by(token: application_token)
    return unless application

    application.increment!(:messages_count)
  end
end
