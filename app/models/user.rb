class User < ApplicationRecord
  has_many :characters, dependent: :destroy
  has_many :personas, dependent: :destroy
  has_many :conversations, through: :personas

  validates :email, presence: true, uniqueness: true
  validates :github_id, uniqueness: true, allow_nil: true

  def is_admin
    admin_email = ENV["ADMIN_EMAIL"]
    admin_email.present? && email == admin_email
  end
end
