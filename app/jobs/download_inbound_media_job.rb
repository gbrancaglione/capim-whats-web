class DownloadInboundMediaJob < ApplicationJob
  queue_as :default

  retry_on Adapters::Whatsapp::CloudApi::ApiError,
           wait: :polynomially_longer, attempts: 5 do |job, error|
    job.send(:mark_failed!, job.arguments.first, error.message)
  end
  retry_on Faraday::TimeoutError, Faraday::ConnectionFailed,
           wait: :polynomially_longer, attempts: 5 do |job, error|
    job.send(:mark_failed!, job.arguments.first, error.message)
  end

  discard_on ActiveRecord::RecordNotFound

  def perform(message_id)
    message = Message.find(message_id)

    return unless message.media_pending?

    result = Whatsapp::Client.new.download_media(media_id: message.whatsapp_media_id)

    message.media.attach(
      io: StringIO.new(result.bytes),
      filename: message.media_filename.presence || filename_for(message, result),
      content_type: result.mime_type
    )
    message.update!(
      media_status: :downloaded,
      media_mime_type: result.mime_type
    )
    ConversationBroadcaster.broadcast_message_update(message)
  end

  private

  def mark_failed!(message_or_id, reason)
    message = message_or_id.is_a?(Message) ? message_or_id : Message.find_by(id: message_or_id)
    return unless message
    message.update!(media_status: :failed, error_message: reason)
    ConversationBroadcaster.broadcast_message_update(message)
  end

  def filename_for(message, result)
    return result.filename if result.filename.present?

    ext = extension_for(result.mime_type)
    prefix =
      case message.message_type
      when "image"    then "image"
      when "audio"    then message.voice? ? "voice" : "audio"
      when "video"    then "video"
      when "document" then "document"
      when "sticker"  then "sticker"
      else                 "media"
      end

    "#{prefix}_#{message.whatsapp_media_id}#{ext}"
  end

  def extension_for(mime_type)
    return "" if mime_type.blank?
    case mime_type
    when %r{^image/jpeg} then ".jpg"
    when %r{^image/png}  then ".png"
    when %r{^image/webp} then ".webp"
    when %r{^image/gif}  then ".gif"
    when %r{^audio/ogg}  then ".ogg"
    when %r{^audio/mpeg} then ".mp3"
    when %r{^audio/mp4}  then ".m4a"
    when %r{^audio/aac}  then ".aac"
    when %r{^video/mp4}  then ".mp4"
    when %r{^video/3gpp} then ".3gp"
    when %r{^application/pdf} then ".pdf"
    else ""
    end
  end
end
