class ConversationThread
  def self.from(conversation)
    new(conversation)
  end

  def initialize(conversation)
    @conversation = conversation
  end

  def id            = @conversation.id
  def to_param      = @conversation.to_param
  def to_key        = [ @conversation.id ]
  def persisted?    = true
  def model_name    = Conversation.model_name
  def contact_id    = @conversation.contact.id
  def contact_phone = @conversation.contact.phone_number

  def contact_display_name
    contact = @conversation.contact
    contact.name.presence || contact.phone_number.presence || contact.user_id
  end

  def contact_display_initial
    contact = @conversation.contact
    (contact.name || contact.phone_number || "?").to_s.first.upcase
  end
end
