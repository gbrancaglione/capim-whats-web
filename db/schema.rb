# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_16_200000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "parent_user_id"
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.string "user_id"
    t.string "username"
    t.string "wa_id"
    t.index ["parent_user_id"], name: "index_contacts_on_parent_user_id"
    t.index ["phone_number"], name: "index_contacts_on_phone_number", unique: true, where: "(phone_number IS NOT NULL)"
    t.index ["user_id"], name: "index_contacts_on_user_id", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["username"], name: "index_contacts_on_username"
    t.index ["wa_id"], name: "index_contacts_on_wa_id"
    t.check_constraint "phone_number IS NOT NULL OR user_id IS NOT NULL", name: "contacts_must_have_identifier"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "customer_service_window_expires_at"
    t.datetime "last_message_at"
    t.string "last_message_preview"
    t.string "status", default: "active", null: false
    t.integer "unread_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_conversations_on_contact_id", unique: true
    t.index ["last_message_at"], name: "index_conversations_on_last_message_at"
    t.index ["status"], name: "index_conversations_on_status"
  end

  create_table "message_templates", force: :cascade do |t|
    t.string "category"
    t.jsonb "components", default: {}
    t.datetime "created_at", null: false
    t.string "language", null: false
    t.string "name", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["name", "language"], name: "index_message_templates_on_name_and_language", unique: true
    t.index ["status"], name: "index_message_templates_on_status"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.bigint "contact_id", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.string "direction", null: false
    t.integer "error_code"
    t.string "error_message"
    t.string "media_filename"
    t.string "media_mime_type"
    t.string "media_status"
    t.string "message_type", default: "text", null: false
    t.datetime "read_at"
    t.datetime "sent_at"
    t.string "status", default: "pending", null: false
    t.string "template_name"
    t.jsonb "template_parameters", default: {}
    t.datetime "updated_at", null: false
    t.boolean "voice", default: false, null: false
    t.string "whatsapp_media_id"
    t.string "whatsapp_message_id"
    t.index ["contact_id"], name: "index_messages_on_contact_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["direction"], name: "index_messages_on_direction"
    t.index ["media_status"], name: "index_messages_on_media_status"
    t.index ["message_type"], name: "index_messages_on_message_type"
    t.index ["status"], name: "index_messages_on_status"
    t.index ["whatsapp_media_id"], name: "index_messages_on_whatsapp_media_id"
    t.index ["whatsapp_message_id"], name: "index_messages_on_whatsapp_message_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "contacts"
  add_foreign_key "messages", "contacts"
  add_foreign_key "messages", "conversations"
end
