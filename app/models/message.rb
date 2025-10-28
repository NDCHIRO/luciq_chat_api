class Message < ApplicationRecord
  belongs_to :chat, counter_cache: true

  before_validation :assign_number, on: :create

  validates :number, presence: true
  validates :body, presence: true

  private

  def assign_number
    last_number = chat.messages.maximum(:number) || 0
    self.number = last_number + 1
  end
end