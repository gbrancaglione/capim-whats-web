class ProcessInboundWebhookJob < ApplicationJob
  queue_as :default

  STATUS_RANK = { "pending" => 0, "sent" => 1, "delivered" => 2, "read" => 3 }.freeze

  def perform(payload)
    parser = Whatsapp::WebhookParser.new
    results = parser.parse(payload)

    results[:messages].each { |msg| process_message(msg) }
    results[:statuses].each { |status| process_status(status) }
  end

  private

  def process_message(parsed)
    contact = Contact.find_or_create_from_webhook(
      phone_number: parsed.phone_number,
      user_id: parsed.user_id,
      parent_user_id: parsed.parent_user_id,
      name: parsed.name,
      username: parsed.username,
      wa_id: parsed.wa_id
    )

    conversation = contact.conversation || contact.create_conversation!
    conversation.update_service_window!

    return if Message.exists?(whatsapp_message_id: parsed.message_id)

    message = conversation.messages.create!(
      build_message_attrs(parsed, contact)
    )

    DownloadInboundMediaJob.perform_later(message.id) if message.media?

    conversation.increment_unread!
    conversation.update_last_message!(message)
    ConversationBroadcaster.broadcast_new_message(conversation, message)
  end

  def build_message_attrs(parsed, contact)
    attrs = {
      contact: contact,
      whatsapp_message_id: parsed.message_id,
      direction: :inbound,
      status: :delivered,
      message_type: parsed.message_type.presence_in(Message.message_types.keys) || "text",
      body: parsed.body,
      delivered_at: parsed.timestamp
    }

    if Message::MEDIA_TYPES.include?(parsed.message_type)
      attrs[:whatsapp_media_id] = parsed.media_id
      attrs[:media_mime_type]   = parsed.media_mime_type
      attrs[:media_filename]    = parsed.media_filename
      attrs[:media_status]      = :pending
      attrs[:voice]             = parsed.voice
    end

    attrs
  end

  def process_status(parsed)
    message = Message.find_by(whatsapp_message_id: parsed.message_id)
    return unless message
    return if message.failed? && parsed.status != "failed"

    attrs = {}

    case parsed.status
    when "sent"
      attrs[:sent_at] = parsed.timestamp if message.sent_at.nil?
    when "delivered"
      attrs[:delivered_at] = parsed.timestamp if message.delivered_at.nil?
    when "read"
      attrs[:read_at] = parsed.timestamp if message.read_at.nil?
    when "failed"
      attrs[:error_code]    = parsed.error_code
      attrs[:error_message] = parsed.error_message
    else
      return
    end

    attrs[:status] = parsed.status if status_advances?(message.status, parsed.status)
    return if attrs.empty?

    message.update!(attrs)
    ConversationBroadcaster.broadcast_message_update(message)
  end

  def status_advances?(current, incoming)
    return false if current == "failed"
    return true  if incoming == "failed"
    (STATUS_RANK[incoming] || -1) > (STATUS_RANK[current] || -1)
  end
end
