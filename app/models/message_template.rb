class MessageTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :language }
  validates :language, presence: true

  scope :approved, -> { where(status: "APPROVED") }
end
