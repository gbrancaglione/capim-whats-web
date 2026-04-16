class SyncTemplatesJob < ApplicationJob
  queue_as :default

  def perform
    client = Whatsapp::Client.new
    client.sync_templates
  end
end
