class ConversationRow
  def self.from(conversation)
    new(conversation)
  end

  def initialize(conversation)
    @conversation = conversation
  end

  def id                    = @conversation.id
  def to_param              = @conversation.to_param
  def to_key                = [ @conversation.id ]
  def persisted?            = true
  def model_name            = Conversation.model_name
  def last_message_at       = @conversation.last_message_at
  def last_message_preview  = @conversation.last_message_preview
  def unread_count          = @conversation.unread_count
  def unread?               = unread_count.to_i.positive?

  def contact_display_name
    contact.name.presence || contact.phone_number.presence || contact.user_id
  end

  def contact_display_initial
    (contact.name || contact.phone_number || "?").to_s.first.upcase
  end

  private

  def contact
    @conversation.contact
  end
end
