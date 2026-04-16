class MessageRow
  def self.from(message)
    new(message)
  end

  def initialize(message)
    @message = message
  end

  def id           = @message.id
  def to_param     = @message.to_param
  def to_key       = [ @message.id ]
  def persisted?   = true
  def model_name   = Message.model_name
  def direction    = @message.direction
  def status       = @message.status
  def body         = @message.body
  def created_at   = @message.created_at
  def message_type = @message.message_type
  def outbound?    = @message.outbound?
  def media?       = @message.media?
  def media_status = @message.media_status
  def media_pending?    = @message.media_pending?
  def media_downloaded? = @message.media_downloaded?
  def media_failed?     = @message.media_failed?
  def media        = @message.media
end
