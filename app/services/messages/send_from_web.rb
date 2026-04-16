module Messages
  class SendFromWeb
    Result = Data.define(:outcome, :conversation, :message) do
      def ok?             = outcome == :sent
      def blank_body?     = outcome == :blank_body
      def missing_phone?  = outcome == :missing_phone
    end

    def initialize(conversation, body:)
      @conversation = conversation
      @body = body.to_s.strip
    end

    def call
      return Result.new(outcome: :missing_phone, conversation: @conversation, message: nil) if missing_phone?
      return Result.new(outcome: :blank_body,    conversation: @conversation, message: nil) if @body.empty?

      message = nil
      ApplicationRecord.transaction do
        message = @conversation.messages.create!(
          contact: @conversation.contact,
          direction: :outbound,
          status: :pending,
          message_type: :text,
          body: @body
        )
        @conversation.update_last_message!(message)
        SendOutboundMessageJob.perform_later(message.id)
      end

      ConversationBroadcaster.broadcast_new_message(@conversation, message)
      Result.new(outcome: :sent, conversation: @conversation, message: message)
    end

    private

    def missing_phone?
      @conversation.contact.phone_number.blank?
    end
  end
end
