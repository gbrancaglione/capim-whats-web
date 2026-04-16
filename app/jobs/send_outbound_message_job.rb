class SendOutboundMessageJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return unless message&.pending?

    response = Whatsapp::Client.new.send_text(
      phone_number: message.contact.phone_number,
      message: message.body
    )

    message.update!(
      whatsapp_message_id: response.dig("messages", 0, "id"),
      status: :sent,
      sent_at: Time.current
    )
    ConversationBroadcaster.broadcast_message_update(message)
  rescue Adapters::Whatsapp::CloudApi::ApiError => e
    message&.update!(status: :failed, error_message: e.message)
    ConversationBroadcaster.broadcast_message_update(message) if message
  end
end
