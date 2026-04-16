class Conversation < ApplicationRecord
  belongs_to :contact
  has_many :messages, dependent: :destroy

  validates :contact_id, uniqueness: true
  validates :status, inclusion: { in: %w[active archived] }

  scope :active, -> { where(status: "active") }
  scope :archived, -> { where(status: "archived") }
  scope :recent, -> { order(last_message_at: :desc) }
  scope :with_unread, -> { where("unread_count > 0") }

  def within_service_window?
    customer_service_window_expires_at.present? && customer_service_window_expires_at > Time.current
  end

  def update_service_window!
    update!(customer_service_window_expires_at: 24.hours.from_now)
  end

  def increment_unread!
    increment!(:unread_count)
  end

  def mark_as_read!
    update!(unread_count: 0)
  end

  def update_last_message!(message)
    update!(
      last_message_at: message.created_at,
      last_message_preview: preview_for(message)
    )
  end

  private

  # Pick a sensible sidebar preview: the caption if the user wrote one,
  # otherwise a type-aware placeholder so media-only messages still show
  # something readable in the conversation list.
  def preview_for(message)
    return message.body.truncate(100) if message.body.present?
    return nil unless message.media?

    case message.message_type
    when "image"    then "📷 Photo"
    when "video"    then "🎥 Video"
    when "audio"    then message.voice? ? "🎤 Voice message" : "🎵 Audio"
    when "document" then "📎 Document"
    when "sticker"  then "🖼️ Sticker"
    end
  end
end
