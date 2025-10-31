class Message < ApplicationRecord
  belongs_to :chat

  before_validation :assign_number, on: :create

  validates :body, presence: true
  validates :number, presence: true, uniqueness: { scope: :chat_id }


  private

  def assign_number
    last_number = chat.messages.maximum(:number) || 0
    self.number = last_number + 1
  end
end