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

ActiveRecord::Schema[7.1].define(version: 2023_11_15_095942) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "annotation_status", ["initial", "awaiting_segmentation_service", "annotatable", "info_asked", "annotated"]
  create_enum "base_unit", ["ml", "g", "kcal"]
  create_enum "collaboration_role", ["manager", "annotator"]
  create_enum "job_log_status", ["initial", "processing", "failed", "succeeded"]
  create_enum "locales", ["en", "de", "fr"]
  create_enum "product_status", ["initial", "incomplete", "complete"]
  create_enum "push_token_platform", ["android", "ios"]

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id", unique: true
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "annotation_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.float "present_quantity"
    t.string "present_unit_id"
    t.float "consumed_quantity"
    t.string "consumed_unit_id"
    t.integer "consumed_percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "annotation_id", null: false
    t.uuid "food_id"
    t.uuid "product_id"
    t.uuid "food_set_id"
    t.uuid "original_food_set_id"
    t.integer "position", default: 0, null: false
    t.boolean "disable_kcal_in_range_validation", default: false, null: false
    t.float "consumed_kcal"
    t.integer "color_index"
    t.index ["annotation_id", "position"], name: "index_annotation_items_on_annotation_id_and_position"
    t.index ["annotation_id"], name: "index_annotation_items_on_annotation_id"
    t.index ["consumed_unit_id"], name: "index_annotation_items_on_consumed_unit_id"
    t.index ["food_id"], name: "index_annotation_items_on_food_id"
    t.index ["food_set_id"], name: "index_annotation_items_on_food_set_id"
    t.index ["original_food_set_id"], name: "index_annotation_items_on_original_food_set_id"
    t.index ["present_quantity"], name: "index_annotation_items_on_present_quantity"
    t.index ["present_unit_id"], name: "index_annotation_items_on_present_unit_id"
    t.index ["product_id"], name: "index_annotation_items_on_product_id"
    t.check_constraint "NOT (product_id IS NOT NULL AND food_id IS NOT NULL)", name: "product_id_and_food_id_exclusive"
  end

  create_table "annotations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dish_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", null: false, enum_type: "annotation_status"
    t.uuid "participation_id", null: false
    t.index ["dish_id"], name: "index_annotations_on_dish_id"
    t.index ["participation_id"], name: "index_annotations_on_participation_id"
  end

  create_table "cohort_food_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cohort_id", null: false
    t.uuid "food_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cohort_id", "food_list_id"], name: "index_cohort_food_lists_on_cohort_id_and_food_list_id", unique: true
    t.index ["cohort_id"], name: "index_cohort_food_lists_on_cohort_id"
    t.index ["food_list_id"], name: "index_cohort_food_lists_on_food_list_id"
  end

  create_table "cohorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "segmentation_client_id", null: false
    t.index ["segmentation_client_id"], name: "index_cohorts_on_segmentation_client_id"
  end

  create_table "collaborations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "collaborator_id", null: false
    t.uuid "cohort_id", null: false
    t.enum "role", null: false, enum_type: "collaboration_role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deactivated_at"
    t.index ["cohort_id"], name: "index_collaborations_on_cohort_id"
    t.index ["collaborator_id", "cohort_id"], name: "index_collaborations_on_collaborator_id_and_cohort_id", unique: true
    t.index ["collaborator_id"], name: "index_collaborations_on_collaborator_id"
  end

  create_table "collaborators", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_token"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "unlock_token"
    t.boolean "admin", default: false, null: false
    t.string "invitation_token"
    t.uuid "inviter_id"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.string "provider", default: "email", null: false
    t.string "uid", null: false
    t.json "tokens"
    t.string "timezone", default: "Etc/UTC", null: false
    t.string "webauthn_id"
    t.index ["email"], name: "index_collaborators_on_email", unique: true
    t.index ["invitation_token"], name: "index_collaborators_on_invitation_token"
    t.index ["inviter_id"], name: "index_collaborators_on_inviter_id"
    t.index ["reset_password_token"], name: "index_collaborators_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_collaborators_on_uid_and_provider", unique: true
    t.index ["unlock_token"], name: "index_collaborators_on_unlock_token", unique: true
    t.index ["webauthn_id"], name: "index_collaborators_on_webauthn_id", unique: true
    t.check_constraint "NOT (name IS NULL AND invitation_token IS NULL)", name: "name_not_null_if_invitation_token_is_null"
    t.check_constraint "NOT (session_token IS NULL AND invitation_token IS NULL)", name: "session_token_not_null_if_invitation_token_is_null"
  end

  create_table "comment_template_translations", force: :cascade do |t|
    t.string "title"
    t.text "message"
    t.string "locale", null: false
    t.uuid "comment_template_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_template_id", "locale"], name: "index_on_comment_template_id_and_locale", unique: true
    t.index ["locale"], name: "index_comment_template_translations_on_locale"
  end

  create_table "comment_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "id_v1"
    t.index ["id_v1"], name: "index_comment_templates_on_id_v1", unique: true
  end

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "message", null: false
    t.uuid "user_id"
    t.uuid "collaborator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "silent", default: false, null: false
    t.uuid "annotation_id", null: false
    t.index ["annotation_id"], name: "index_comments_on_annotation_id"
    t.index ["collaborator_id"], name: "index_comments_on_collaborator_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
    t.check_constraint "(user_id IS NULL) <> (collaborator_id IS NULL)", name: "user_id_and_collaborator_id_present_and_exclusive"
  end

  create_table "countries", id: { type: :string, limit: 2 }, force: :cascade do |t|
    t.index "upper((id)::text)", name: "index_countries_on_UPPER_id", unique: true
  end

  create_table "country_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "locale", null: false
    t.string "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "locale"], name: "index_country_translations_on_country_id_and_locale", unique: true
    t.index ["locale"], name: "index_country_translations_on_locale"
  end

  create_table "dish_images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dish_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id"], name: "index_dish_images_on_dish_id"
  end

  create_table "dishes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "private", default: true, null: false
    t.text "description"
    t.index ["user_id"], name: "index_dishes_on_user_id"
  end

  create_table "food_food_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "food_id", null: false
    t.uuid "food_set_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_id", "food_set_id"], name: "index_food_food_sets_on_food_id_and_food_set_id", unique: true
    t.index ["food_id"], name: "index_food_food_sets_on_food_id"
    t.index ["food_set_id"], name: "index_food_food_sets_on_food_set_id"
  end

  create_table "food_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "country_id", null: false
    t.string "name", null: false
    t.string "source"
    t.string "version"
    t.jsonb "metadata"
    t.boolean "editable", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_food_lists_on_country_id"
    t.index ["name"], name: "index_food_lists_on_name", unique: true
  end

  create_table "food_nutrients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "food_id", null: false
    t.string "nutrient_id", null: false
    t.float "per_hundred", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_id", "nutrient_id"], name: "index_food_nutrients_on_food_id_and_nutrient_id", unique: true
    t.index ["food_id"], name: "index_food_nutrients_on_food_id"
    t.index ["nutrient_id"], name: "index_food_nutrients_on_nutrient_id"
  end

  create_table "food_set_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "locale", null: false
    t.uuid "food_set_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text), locale", name: "index_food_set_translations_on_name_and_locale", unique: true
    t.index ["food_set_id", "locale"], name: "index_food_set_translations_on_food_set_id_and_locale", unique: true
    t.index ["locale"], name: "index_food_set_translations_on_locale"
  end

  create_table "food_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cname", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "tsv_document_en"
    t.tsvector "tsv_document_de"
    t.tsvector "tsv_document_fr"
    t.integer "id_v1"
    t.index ["cname"], name: "index_food_sets_on_cname", unique: true
    t.index ["id_v1"], name: "index_food_sets_on_id_v1", unique: true
    t.index ["tsv_document_de"], name: "index_food_sets_on_tsv_document_de", using: :gin
    t.index ["tsv_document_en"], name: "index_food_sets_on_tsv_document_en", using: :gin
    t.index ["tsv_document_fr"], name: "index_food_sets_on_tsv_document_fr", using: :gin
  end

  create_table "food_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "locale", null: false
    t.uuid "food_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text), locale", name: "index_food_translations_on_name_and_locale"
    t.index ["food_id", "locale"], name: "index_food_translations_on_food_id_and_locale", unique: true
    t.index ["locale"], name: "index_food_translations_on_locale"
  end

  create_table "foods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "unit_id", default: "g", null: false
    t.boolean "annotatable"
    t.boolean "segmentable"
    t.float "fa_ps_ratio"
    t.integer "kcal_min"
    t.integer "kcal_max"
    t.integer "id_v1"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "tsv_document_en"
    t.tsvector "tsv_document_de"
    t.tsvector "tsv_document_fr"
    t.float "portion_quantity"
    t.uuid "food_list_id", null: false
    t.index ["annotatable"], name: "index_foods_on_annotatable"
    t.index ["fa_ps_ratio"], name: "index_foods_on_fa_ps_ratio"
    t.index ["food_list_id"], name: "index_foods_on_food_list_id"
    t.index ["id_v1"], name: "index_foods_on_id_v1", unique: true
    t.index ["kcal_max"], name: "index_foods_on_kcal_max"
    t.index ["kcal_min"], name: "index_foods_on_kcal_min"
    t.index ["segmentable"], name: "index_foods_on_segmentable"
    t.index ["tsv_document_de"], name: "index_foods_on_tsv_document_de", using: :gin
    t.index ["tsv_document_en"], name: "index_foods_on_tsv_document_en", using: :gin
    t.index ["tsv_document_fr"], name: "index_foods_on_tsv_document_fr", using: :gin
    t.index ["unit_id"], name: "index_foods_on_unit_id"
  end

  create_table "intakes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "consumed_at", null: false
    t.string "timezone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "annotation_id", null: false
    t.index ["annotation_id"], name: "index_intakes_on_annotation_id"
  end

  create_table "job_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "job_id"
    t.string "job_name", null: false
    t.enum "status", null: false, enum_type: "job_log_status"
    t.text "logs"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_job_logs_on_created_at"
    t.index ["job_id"], name: "index_job_logs_on_job_id"
    t.index ["job_name"], name: "index_job_logs_on_job_name"
  end

  create_table "nutrient_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "locale", null: false
    t.string "nutrient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_nutrient_translations_on_locale"
    t.index ["nutrient_id", "locale"], name: "index_nutrient_translations_on_nutrient_id_and_locale", unique: true
  end

  create_table "nutrients", id: :string, force: :cascade do |t|
    t.string "unit_id", default: "g", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_nutrients_on_unit_id"
  end

  create_table "participations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "cohort_id", null: false
    t.text "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "associated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.index ["cohort_id", "user_id"], name: "index_participations_on_cohort_id_and_user_id", unique: true
    t.index ["cohort_id"], name: "index_participations_on_cohort_id"
    t.index ["key"], name: "index_participations_on_key", unique: true
    t.index ["user_id"], name: "index_participations_on_user_id"
    t.check_constraint "NOT (started_at >= ended_at AND started_at IS NOT NULL AND ended_at IS NOT NULL)", name: "started_at_before_ended_at"
    t.exclusion_constraint "user_id WITH =, tsrange(started_at, ended_at) WITH &&", using: :gist, name: "no_overlapping_time_ranges"
  end

  create_table "polygon_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dish_image_id", null: false
    t.uuid "annotation_item_id", null: false
    t.uuid "segmentation_client_id"
    t.json "polygons", null: false
    t.float "ml_confidence"
    t.json "ml_dimensions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annotation_item_id"], name: "index_polygon_sets_on_annotation_item_id"
    t.index ["dish_image_id", "annotation_item_id"], name: "index_polygon_sets_on_dish_image_id_and_annotation_item_id", unique: true
    t.index ["dish_image_id"], name: "index_polygon_sets_on_dish_image_id"
    t.index ["segmentation_client_id"], name: "index_polygon_sets_on_segmentation_client_id"
  end

  create_table "product_images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_nutrients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "product_id", null: false
    t.string "nutrient_id", null: false
    t.float "per_hundred", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nutrient_id"], name: "index_product_nutrients_on_nutrient_id"
    t.index ["product_id", "nutrient_id"], name: "index_product_nutrients_on_product_id_and_nutrient_id", unique: true
    t.index ["product_id"], name: "index_product_nutrients_on_product_id"
  end

  create_table "product_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "locale", null: false
    t.uuid "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_product_translations_on_locale"
    t.index ["product_id", "locale"], name: "index_product_translations_on_product_id_and_locale", unique: true
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "barcode", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "fetched_at"
    t.string "image_url"
    t.string "unit_id", default: "g", null: false
    t.float "portion_quantity"
    t.text "source"
    t.enum "status", null: false, enum_type: "product_status"
    t.tsvector "tsv_document_en"
    t.tsvector "tsv_document_de"
    t.tsvector "tsv_document_fr"
    t.index ["barcode"], name: "index_products_on_barcode"
    t.index ["tsv_document_de"], name: "index_products_on_tsv_document_de", using: :gin
    t.index ["tsv_document_en"], name: "index_products_on_tsv_document_en", using: :gin
    t.index ["tsv_document_fr"], name: "index_products_on_tsv_document_fr", using: :gin
    t.index ["unit_id"], name: "index_products_on_unit_id"
  end

  create_table "push_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "push_token_id", null: false
    t.uuid "comment_id"
    t.text "message", null: false
    t.json "data"
    t.datetime "sent_at"
    t.text "response_status"
    t.text "response_body"
    t.text "error_message"
    t.integer "badge"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_push_notifications_on_comment_id"
    t.index ["push_token_id"], name: "index_push_notifications_on_push_token_id"
  end

  create_table "push_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.enum "platform", null: false, enum_type: "push_token_platform"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deactivated_at"
    t.enum "locale", default: "en", null: false, enum_type: "locales"
    t.index "lower((token)::text)", name: "index_push_tokens_on_lower_token_text", unique: true, where: "(deactivated_at IS NULL)"
    t.index ["user_id"], name: "index_push_tokens_on_user_id"
  end

  create_table "segmentation_clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.text "ml_model", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ml_model"], name: "index_segmentation_clients_on_ml_model", unique: true
    t.index ["name"], name: "index_segmentation_clients_on_name", unique: true
  end

  create_table "segmentations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dish_image_id", null: false
    t.uuid "segmentation_client_id"
    t.text "task_id"
    t.string "status", null: false
    t.integer "response_code"
    t.json "response_body"
    t.text "ai_model", comment: "name and version of the AI algorithm from which the data came"
    t.datetime "started_at"
    t.datetime "response_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "error_kind"
    t.uuid "annotation_id", null: false
    t.index ["annotation_id"], name: "index_segmentations_on_annotation_id"
    t.index ["dish_image_id"], name: "index_segmentations_on_dish_image_id"
    t.index ["response_at"], name: "index_segmentations_on_response_at"
    t.index ["segmentation_client_id"], name: "index_segmentations_on_segmentation_client_id"
    t.index ["started_at"], name: "index_segmentations_on_started_at"
    t.index ["status"], name: "index_segmentations_on_status"
    t.index ["task_id"], name: "index_segmentations_on_task_id"
  end

  create_table "units", id: :string, force: :cascade do |t|
    t.float "factor", null: false
    t.enum "base_unit", null: false, enum_type: "base_unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_units_on_lower_id_text", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.boolean "anonymous", default: false, null: false
    t.boolean "allow_password_change", default: false, null: false
    t.boolean "dishes_private", default: true, null: false
    t.text "note"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit", null: false
    t.uuid "user_id"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["user_id"], name: "index_versions_on_user_id"
  end

  create_table "webauthn_credentials", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "collaborator_id", null: false
    t.string "external_id", null: false
    t.string "public_key", null: false
    t.string "nickname", null: false
    t.integer "sign_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collaborator_id"], name: "index_webauthn_credentials_on_collaborator_id"
    t.index ["external_id"], name: "index_webauthn_credentials_on_external_id", unique: true
    t.index ["nickname", "collaborator_id"], name: "index_webauthn_credentials_on_nickname_and_collaborator_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "annotation_items", "annotations"
  add_foreign_key "annotation_items", "food_sets"
  add_foreign_key "annotation_items", "food_sets", column: "original_food_set_id"
  add_foreign_key "annotation_items", "foods"
  add_foreign_key "annotation_items", "products"
  add_foreign_key "annotation_items", "units", column: "consumed_unit_id"
  add_foreign_key "annotation_items", "units", column: "present_unit_id"
  add_foreign_key "annotations", "dishes"
  add_foreign_key "annotations", "participations"
  add_foreign_key "cohort_food_lists", "cohorts"
  add_foreign_key "cohort_food_lists", "food_lists"
  add_foreign_key "cohorts", "segmentation_clients"
  add_foreign_key "collaborations", "cohorts"
  add_foreign_key "collaborations", "collaborators"
  add_foreign_key "collaborators", "collaborators", column: "inviter_id"
  add_foreign_key "comment_template_translations", "comment_templates"
  add_foreign_key "comments", "annotations"
  add_foreign_key "comments", "collaborators"
  add_foreign_key "comments", "users"
  add_foreign_key "country_translations", "countries"
  add_foreign_key "dish_images", "dishes"
  add_foreign_key "dishes", "users"
  add_foreign_key "food_food_sets", "food_sets"
  add_foreign_key "food_food_sets", "foods"
  add_foreign_key "food_lists", "countries"
  add_foreign_key "food_nutrients", "foods"
  add_foreign_key "food_nutrients", "nutrients"
  add_foreign_key "food_set_translations", "food_sets"
  add_foreign_key "food_translations", "foods"
  add_foreign_key "foods", "food_lists"
  add_foreign_key "foods", "units"
  add_foreign_key "intakes", "annotations"
  add_foreign_key "nutrient_translations", "nutrients"
  add_foreign_key "nutrients", "units"
  add_foreign_key "participations", "cohorts"
  add_foreign_key "participations", "users"
  add_foreign_key "polygon_sets", "annotation_items"
  add_foreign_key "polygon_sets", "dish_images"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_nutrients", "nutrients"
  add_foreign_key "product_nutrients", "products"
  add_foreign_key "product_translations", "products"
  add_foreign_key "products", "units"
  add_foreign_key "push_notifications", "push_tokens"
  add_foreign_key "push_tokens", "users"
  add_foreign_key "segmentations", "annotations"
  add_foreign_key "segmentations", "dish_images"
  add_foreign_key "segmentations", "segmentation_clients"
  add_foreign_key "versions", "users"
  add_foreign_key "webauthn_credentials", "collaborators"
end
