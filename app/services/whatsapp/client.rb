module Whatsapp
  class Client
    def initialize(adapter: nil)
      @adapter = adapter || default_adapter
    end

    def send_text(phone_number:, message:)
      @adapter.send_text(phone_number: phone_number, message: message)
    end

    def send_template(phone_number:, template_name:, language:, parameters: [])
      @adapter.send_template(
        phone_number: phone_number,
        template_name: template_name,
        language: language,
        parameters: parameters
      )
    end

    def mark_as_read(message_id:)
      @adapter.mark_as_read(message_id: message_id)
    end

    def download_media(media_id:)
      @adapter.download_media(media_id: media_id)
    end

    def sync_templates
      config = Rails.application.config.whatsapp
      templates = @adapter.fetch_templates(business_account_id: config[:business_account_id])

      templates.each do |template_data|
        MessageTemplate.find_or_initialize_by(
          name: template_data["name"],
          language: template_data["language"]
        ).update!(
          category: template_data["category"],
          status: template_data["status"],
          components: template_data["components"] || {}
        )
      end
    end

    private

    def default_adapter
      Adapters::Whatsapp::CloudApi.new
    end
  end
end
