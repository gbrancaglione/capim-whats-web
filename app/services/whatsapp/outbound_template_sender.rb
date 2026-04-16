module Whatsapp
  class OutboundTemplateSender
    Result = Data.define(:message, :conversation)

    def initialize(client: Whatsapp::Client.new)
      @client = client
    end

    def call(phone_number:, template_name:, language:, parameters: [], contact: nil)
      contact ||= Contact.find_or_create_from_webhook(phone_number: phone_number)
      conversation = contact.conversation || contact.create_conversation!

      response = @client.send_template(
        phone_number: phone_number,
        template_name: template_name,
        language: language,
        parameters: parameters
      )

      message = conversation.messages.create!(
        contact: contact,
        whatsapp_message_id: response.dig("messages", 0, "id"),
        direction: :outbound,
        status: :sent,
        message_type: :template,
        template_name: template_name,
        template_parameters: parameters,
        sent_at: Time.current
      )

      conversation.update_last_message!(message)
      ConversationBroadcaster.broadcast_new_message(conversation, message)

      Result.new(message: message, conversation: conversation)
    end
  end
end
