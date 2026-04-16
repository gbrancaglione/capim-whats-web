class Contact < ApplicationRecord
  has_one :conversation, dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :phone_number,
            uniqueness: true,
            format: { with: /\A\+[1-9]\d{1,14}\z/, message: "must be in E.164 format" },
            allow_nil: true
  validates :user_id, uniqueness: true, allow_nil: true
  validate :must_have_identifier

  scope :leads, -> { left_joins(:conversation).where(conversations: { id: nil }) }
  scope :with_conversation, -> { joins(:conversation) }

  # Upsert a contact from a parsed webhook. Matches on user_id (BSUID) first,
  # then phone_number. At least one must be present.
  def self.find_or_create_from_webhook(phone_number: nil, user_id: nil, parent_user_id: nil, name: nil, username: nil, wa_id: nil)
    if phone_number.blank? && user_id.blank?
      raise ArgumentError, "phone_number or user_id required"
    end

    contact = find_by(user_id: user_id) if user_id.present?
    contact ||= find_by(phone_number: phone_number) if phone_number.present?
    contact ||= new

    contact.phone_number ||= phone_number
    contact.user_id ||= user_id
    contact.parent_user_id = parent_user_id if parent_user_id.present?
    contact.name = name if name.present?
    contact.username = username if username.present?
    contact.wa_id = wa_id if wa_id.present?
    contact.save!
    contact
  end

  private

  def must_have_identifier
    if phone_number.blank? && user_id.blank?
      errors.add(:base, "must have a phone_number or user_id")
    end
  end
end
