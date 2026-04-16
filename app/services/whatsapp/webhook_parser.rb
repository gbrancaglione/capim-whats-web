module Whatsapp
  class WebhookParser
    MEDIA_TYPES = %w[image audio video document sticker].freeze

    ParsedMessage = Data.define(
      :phone_number, :name, :username, :wa_id,
      :user_id, :parent_user_id,
      :message_id, :message_type, :body, :timestamp,
      :media_id, :media_mime_type, :media_filename, :voice
    )

    StatusUpdate = Data.define(:message_id, :status, :timestamp, :error_code, :error_message)

    def parse(payload)
      entries = payload["entry"] || []
      results = { messages: [], statuses: [] }

      entries.each do |entry|
        changes = entry["changes"] || []
        changes.each do |change|
          value = change["value"] || {}

          contact_map = build_contact_map(value["contacts"] || [])

          parse_messages(value, contact_map, results)
          parse_statuses(value, results)
        end
      end

      results
    end

    private

    def build_contact_map(contacts)
      map = {}
      contacts.each do |c|
        map[c["user_id"]] = c if c["user_id"].present?
        map[c["wa_id"]] = c if c["wa_id"].present?
      end
      map
    end

    def parse_messages(value, contact_map, results)
      messages = value["messages"] || []

      messages.each do |msg|
        from_user_id = msg["from_user_id"]
        from_phone = msg["from"]

        contact = contact_map[from_user_id] || contact_map[from_phone] || {}
        profile = contact["profile"] || {}

        wa_id = contact["wa_id"] || from_phone
        phone_number = normalize_phone(wa_id)
        media = extract_media(msg)

        results[:messages] << ParsedMessage.new(
          phone_number: phone_number,
          name: profile["name"],
          username: profile["username"],
          wa_id: wa_id,
          user_id: contact["user_id"] || from_user_id,
          parent_user_id: contact["parent_user_id"] || msg["from_parent_user_id"],
          message_id: msg["id"],
          message_type: msg["type"],
          body: extract_body(msg),
          timestamp: Time.at(msg["timestamp"].to_i),
          media_id: media[:id],
          media_mime_type: media[:mime_type],
          media_filename: media[:filename],
          voice: media[:voice]
        )
      end
    end

    def parse_statuses(value, results)
      statuses = value["statuses"] || []

      statuses.each do |status|
        error = (status["errors"] || []).first || {}

        results[:statuses] << StatusUpdate.new(
          message_id: status["id"],
          status: status["status"],
          timestamp: Time.at(status["timestamp"].to_i),
          error_code: error["code"],
          error_message: error["message"] || error["title"]
        )
      end
    end

    def extract_body(msg)
      case msg["type"]
      when "text"
        msg.dig("text", "body")
      when "image", "video", "document"
        msg.dig(msg["type"], "caption")
      end
    end

    def extract_media(msg)
      type = msg["type"]
      return {} unless MEDIA_TYPES.include?(type)

      blob = msg[type] || {}
      {
        id:        blob["id"],
        mime_type: blob["mime_type"],
        filename:  blob["filename"],
        voice:     type == "audio" && blob["voice"] == true
      }
    end

    def normalize_phone(raw)
      return nil if raw.blank?
      "+#{raw.to_s.delete_prefix('+')}"
    end
  end
end
