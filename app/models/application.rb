class Application < ApplicationRecord
  has_many :chats, dependent: :destroy

  before_validation :generate_token, on: :create

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  private

  def generate_token
    self.token ||= SecureRandom.hex(16)
  end
end