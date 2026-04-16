ContactDetail = Data.define(
  :id,
  :name,
  :phone_number,
  :user_id,
  :conversation_id
) do
  def self.from(contact)
    new(
      id: contact.id,
      name: contact.name,
      phone_number: contact.phone_number,
      user_id: contact.user_id,
      conversation_id: contact.conversation&.id
    )
  end

  def conversation?   = !conversation_id.nil?
  def display_name    = name.presence || phone_number.presence || user_id
  def display_initial = (name || phone_number || "?").to_s.first.upcase
  def user_id?        = user_id.present?
  def name?           = name.present?
  def phone_number?   = phone_number.present?
end
