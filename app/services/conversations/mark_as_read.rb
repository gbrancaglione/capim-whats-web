module Conversations
  class MarkAsRead
    def initialize(conversation, client: Whatsapp::Client.new)
      @conversation = conversation
      @client = client
    end

    def call
      return if @conversation.unread_count.to_i.zero?

      send_read_receipt
      @conversation.mark_as_read!
      ConversationBroadcaster.refresh_sidebar_row(@conversation)
    end

    private

    def send_read_receipt
      last_inbound = @conversation.messages.inbound.recent.first
      return if last_inbound&.whatsapp_message_id.blank?

      @client.mark_as_read(message_id: last_inbound.whatsapp_message_id)
    rescue Adapters::Whatsapp::CloudApi::ApiError
      # The read receipt is best-effort; the local badge still clears.
    end
  end
end
