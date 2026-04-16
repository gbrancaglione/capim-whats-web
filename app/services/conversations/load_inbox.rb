module Conversations
  class LoadInbox
    LIMIT = 100

    def self.call = new.call

    def call
      Conversation
        .includes(:contact)
        .active
        .recent
        .limit(LIMIT)
        .map { |conversation| ConversationRow.from(conversation) }
    end
  end
end
