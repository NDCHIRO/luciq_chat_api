class Application < ApplicationRecord
  has_many :chats, dependent: :destroy

  before_create :generate_token

  validates :name, presence: true
  validates :token, uniqueness: true

  private

  def generate_token
    self.token = SecureRandom.hex(16)
  end
end