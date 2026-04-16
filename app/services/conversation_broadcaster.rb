class ConversationBroadcaster
  class << self
    def broadcast_new_message(conversation, message)
      append_message_to_thread(conversation, message)
      refresh_sidebar_row(conversation)
    end

    def broadcast_message_update(message)
      row = MessageRow.from(message)
      Turbo::StreamsChannel.broadcast_replace_to(
        "conversation_#{message.conversation_id}",
        target: ActionView::RecordIdentifier.dom_id(row),
        partial: "messages/message",
        locals: { message: row }
      )
    end

    def refresh_sidebar_row(conversation)
      row = ConversationRow.from(conversation)
      Turbo::StreamsChannel.broadcast_remove_to(
        "conversations",
        target: ActionView::RecordIdentifier.dom_id(row)
      )
      Turbo::StreamsChannel.broadcast_prepend_to(
        "conversations",
        target: "conversations_list",
        partial: "conversations/conversation_row",
        locals: { row: row }
      )
    end

    private

    def append_message_to_thread(conversation, message)
      Turbo::StreamsChannel.broadcast_append_to(
        "conversation_#{conversation.id}",
        target: "messages",
        partial: "messages/message",
        locals: { message: MessageRow.from(message) }
      )
    end
  end
end
