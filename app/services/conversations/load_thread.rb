module Conversations
  class LoadThread
    PAGE_SIZE = 100

    Result = Data.define(:thread, :messages)

    def initialize(conversation)
      @conversation = conversation
    end

    def call
      rows = @conversation.messages
                          .order(created_at: :desc)
                          .limit(PAGE_SIZE)
                          .to_a
                          .reverse
                          .map { |m| MessageRow.from(m) }
      Result.new(
        thread: ConversationThread.from(@conversation),
        messages: rows
      )
    end
  end
end
