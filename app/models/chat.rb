class Chat < ApplicationRecord
  belongs_to :application
  has_many :messages, dependent: :destroy
  
  before_validation :assign_number, on: :create

  validates :application_id, presence: true
  validates :number, presence: true, uniqueness: { scope: :application_id }

  private

  def assign_number
    last_number = application.chats.maximum(:number) || 0
    self.number = last_number + 1
  end
end
