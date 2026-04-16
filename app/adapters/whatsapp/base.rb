module Adapters
  module Whatsapp
    class Base
      def send_text(phone_number:, message:)
        raise NotImplementedError
      end

      def send_template(phone_number:, template_name:, language:, parameters: [])
        raise NotImplementedError
      end

      def mark_as_read(message_id:)
        raise NotImplementedError
      end

      def fetch_templates(business_account_id:)
        raise NotImplementedError
      end

      def download_media(media_id:)
        raise NotImplementedError
      end
    end
  end
end
