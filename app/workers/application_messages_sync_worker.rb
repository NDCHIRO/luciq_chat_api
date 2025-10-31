class ApplicationMessagesSyncWorker
  include Sidekiq::Worker

  def perform(application_id)
    app = Application.find_by(id: application_id)
    return unless app

    redis_total = 0
    app.chats.find_each do |chat|
      redis_total += REDIS.get("chat:#{chat.id}:messages_count").to_i
    end

    # Update MySQL if higher
    if redis_total > app.messages_count
      app.update_column(:messages_count, redis_total)
    end
  end
end
