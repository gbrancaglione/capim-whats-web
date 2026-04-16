class ConversationReadsController < ApplicationController
  def create
    conversation = Conversation.find(params[:conversation_id])
    Conversations::MarkAsRead.new(conversation).call
    redirect_to conversation_path(conversation)
  end
end
