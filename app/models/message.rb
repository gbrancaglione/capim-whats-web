class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :contact

  has_one_attached :media

  MEDIA_TYPES = %w[image audio video document sticker].freeze

  enum :direction, { inbound: "inbound", outbound: "outbound" }
  enum :status, { pending: "pending", sent: "sent", delivered: "delivered", read: "read", failed: "failed" }
  enum :message_type, {
    text:     "text",
    template: "template",
    image:    "image",
    audio:    "audio",
    video:    "video",
    document: "document",
    sticker:  "sticker"
  }
  enum :media_status, {
    pending:    "pending",
    downloaded: "downloaded",
    failed:     "failed"
  }, prefix: :media

  validates :direction, presence: true
  validates :status, presence: true
  validates :message_type, presence: true
  validates :whatsapp_message_id, uniqueness: true, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }

  def media?
    MEDIA_TYPES.include?(message_type)
  end
end
