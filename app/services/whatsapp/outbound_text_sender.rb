module Whatsapp
  class OutboundTextSender
    Result = Data.define(:message, :conversation)

    def initialize(client: Whatsapp::Client.new)
      @client = client
    end

    def call(phone_number:, body:)
      response = @client.send_text(phone_number: phone_number, message: body)

      contact = Contact.find_or_create_from_webhook(phone_number: phone_number)
      conversation = contact.conversation || contact.create_conversation!

      message = conversation.messages.create!(
        contact: contact,
        whatsapp_message_id: response.dig("messages", 0, "id"),
        direction: :outbound,
        status: :sent,
        message_type: :text,
        body: body,
        sent_at: Time.current
      )

      conversation.update_last_message!(message)
      ConversationBroadcaster.broadcast_new_message(conversation, message)

      Result.new(message: message, conversation: conversation)
    end
  end
end
