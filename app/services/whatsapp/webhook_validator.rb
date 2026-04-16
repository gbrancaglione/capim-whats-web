module Whatsapp
  class WebhookValidator
    def initialize(app_secret: nil)
      @app_secret = app_secret || Rails.application.credentials.whatsapp[:app_secret]
    end

    def valid_signature?(payload:, signature_header:)
      return false if signature_header.blank?

      expected_signature = OpenSSL::HMAC.hexdigest("SHA256", @app_secret, payload)
      received_signature = signature_header.sub("sha256=", "")

      ActiveSupport::SecurityUtils.secure_compare(expected_signature, received_signature)
    end
  end
end
