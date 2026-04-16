module Adapters
  module Whatsapp
    class CloudApi < Base
      DownloadedMedia = Data.define(:bytes, :mime_type, :sha256, :file_size, :filename)

      # Faraday (via Faraday::NestedParamsEncoder) alphabetizes query params
      # when it re-serializes a URL. Meta's media CDN (lookaside.fbsbx.com)
      # computes its signature over the ORIGINAL param order — so the default
      # encoder produces an HTTP 404. We install this encoder only on the CDN
      # download connection so the rest of the adapter is untouched.
      module PreserveOrderParamsEncoder
        def self.encode(params)
          return nil if params.nil?
          params.map { |k, v|
            [ Faraday::Utils.escape(k), Faraday::Utils.escape(v) ].join("=")
          }.join("&")
        end

        def self.decode(query)
          return nil if query.nil?
          query.split("&").map do |pair|
            k, v = pair.split("=", 2)
            [ Faraday::Utils.unescape(k), Faraday::Utils.unescape(v.to_s) ]
          end
        end
      end

      DEFAULT_MAX_FILE_SIZE_BYTES = 100_000_000

      def initialize
        @config = Rails.application.config.whatsapp
        @connection = build_connection
      end

      def send_text(phone_number:, message:)
        post_message(
          messaging_product: "whatsapp",
          to: phone_number,
          type: "text",
          text: { body: message }
        )
      end

      def send_template(phone_number:, template_name:, language:, parameters: [])
        components = []
        if parameters.any?
          components << {
            type: "body",
            parameters: parameters.map { |p| { type: "text", text: p } }
          }
        end

        post_message(
          messaging_product: "whatsapp",
          to: phone_number,
          type: "template",
          template: {
            name: template_name,
            language: { code: language },
            components: components
          }
        )
      end

      def mark_as_read(message_id:)
        post_message(
          messaging_product: "whatsapp",
          status: "read",
          message_id: message_id
        )
      end

      def fetch_templates(business_account_id:)
        response = @connection.get("#{@config[:api_version]}/#{business_account_id}/message_templates")
        body = JSON.parse(response.body)
        raise ApiError, body["error"]["message"] if body["error"]
        body["data"] || []
      end

      # WhatsApp media is two-hop:
      #   1. GET /{media_id} returns a short-lived signed URL + metadata
      #   2. GET <url> (same bearer) returns the raw bytes
      def download_media(media_id:)
        metadata = fetch_media_metadata(media_id)
        enforce_size_limit!(metadata["file_size"])
        bytes = fetch_media_bytes(metadata["url"])
        enforce_size_limit!(bytes.bytesize)

        DownloadedMedia.new(
          bytes: bytes,
          mime_type: metadata["mime_type"],
          sha256: metadata["sha256"],
          file_size: bytes.bytesize,
          filename: nil
        )
      end

      private

      def post_message(payload)
        response = @connection.post(
          "#{@config[:api_version]}/#{@config[:phone_number_id]}/messages",
          payload.to_json,
          "Content-Type" => "application/json"
        )
        body = JSON.parse(response.body)
        raise ApiError, body["error"]["message"] if body["error"]
        body
      end

      def fetch_media_metadata(media_id)
        response = @connection.get("#{@config[:api_version]}/#{media_id}")
        body = parse_json(response.body)
        raise ApiError, body.dig("error", "message") || "Unknown error" if body["error"]
        raise ApiError, "Missing media url" if body["url"].blank?
        body
      end

      def fetch_media_bytes(url)
        download_conn = Faraday.new do |f|
          f.options.timeout = media_config[:download_timeout_seconds] || 60
          f.options.open_timeout = 5
          f.options.params_encoder = PreserveOrderParamsEncoder
          f.headers["User-Agent"] = "CapimWhatsWeb/1.0"
          f.request :authorization, "Bearer", -> { credentials[:access_token] }
          f.adapter Faraday.default_adapter
        end

        response = download_conn.get(url)
        raise ApiError, "Media download failed with HTTP #{response.status}" unless response.success?
        raise ApiError, "Media download returned empty body" if response.body.blank?
        response.body
      end

      def enforce_size_limit!(size)
        return if size.nil?
        limit = media_config[:max_file_size_bytes] || DEFAULT_MAX_FILE_SIZE_BYTES
        return if size.to_i <= limit.to_i
        raise ApiError, "Media exceeds size limit (#{size} > #{limit} bytes)"
      end

      def media_config
        @config[:media] || {}
      end

      def parse_json(body)
        return {} if body.blank?
        JSON.parse(body)
      rescue JSON::ParserError
        { "error" => { "message" => "Invalid JSON response from WhatsApp" } }
      end

      def build_connection
        Faraday.new(url: @config[:api_base_url]) do |f|
          f.options.timeout = 10
          f.options.open_timeout = 5
          f.request :authorization, "Bearer", -> { credentials[:access_token] }
          f.adapter Faraday.default_adapter
        end
      end

      def credentials
        Rails.application.credentials.whatsapp || {}
      end

      class ApiError < StandardError; end
    end
  end
end
