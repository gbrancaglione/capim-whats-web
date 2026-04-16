class MessagesController < ApplicationController
  def create
    conversation = Conversation.includes(:contact).find(params[:conversation_id])
    result = Messages::SendFromWeb.new(conversation, body: message_params[:body]).call

    if result.missing_phone?
      redirect_to(conversation_path(conversation), alert: "Cannot send: contact has no phone number.") and return
    end

    respond_to do |format|
      format.turbo_stream { head :no_content }
      format.html         { redirect_to conversation_path(conversation) }
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end
end
