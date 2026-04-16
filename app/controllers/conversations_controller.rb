class ConversationsController < ApplicationController
  def index
    @conversations = Conversations::LoadInbox.call
    @selected_conversation = nil
    @messages = []
  end

  def show
    conversation = Conversation.includes(:contact).find(params[:id])
    Conversations::MarkAsRead.new(conversation).call

    @conversations = Conversations::LoadInbox.call
    result = Conversations::LoadThread.new(conversation).call
    @selected_conversation = result.thread
    @messages = result.messages
    render :index
  end
end
