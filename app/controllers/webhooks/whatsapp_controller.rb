module Webhooks
  class WhatsappController < ApplicationController
    skip_forgery_protection

    def verify
      mode = params["hub.mode"]
      token = params["hub.verify_token"]
      challenge = params["hub.challenge"]

      if mode == "subscribe" && token == verify_token
        render plain: challenge, status: :ok
      else
        head :forbidden
      end
    end

    def receive
      payload = request.body.read
      signature = request.headers["X-Hub-Signature-256"]

      unless validator.valid_signature?(payload: payload, signature_header: signature)
        head :unauthorized
        return
      end

      ProcessInboundWebhookJob.perform_later(JSON.parse(payload))
      head :ok
    end

    private

    def verify_token
      Rails.application.credentials.whatsapp[:verify_token]
    end

    def validator
      @validator ||= Whatsapp::WebhookValidator.new
    end
  end
end
