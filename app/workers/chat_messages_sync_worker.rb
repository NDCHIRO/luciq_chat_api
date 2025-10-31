class ChatMessagesSyncWorker
  include Sidekiq::Worker

  def perform(chat_id = nil)
    if chat_id
      sync_chat(chat_id)
    else
      Chat.find_each { |c| sync_chat(c.id) }
    end
  end

  private

  def sync_chat(chat_id)
    count = REDIS.get("chat:#{chat_id}:messages_count").to_i
    Chat.where(id: chat_id).update_all(messages_count: count)
  end
end