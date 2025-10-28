class Chat < ApplicationRecord
  belongs_to :application, counter_cache: true
  has_many :messages, dependent: :destroy

  before_validation :assign_number, on: :create

  validates :number, presence: true
  validates :application_id, presence: true

  private

  def assign_number
    last_number = application.chats.maximum(:number) || 0
    self.number = last_number + 1
  end
end
