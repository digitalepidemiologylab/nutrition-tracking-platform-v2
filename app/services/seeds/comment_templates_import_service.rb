# frozen_string_literal: true

module Seeds
  class CommentTemplatesImportService
    def initialize
      @s3_seed_import_service = Seeds::S3SeedImportService.new(
        collection_name: "annotation_questions",
        item_hash_lambda: ->(row) {
          {
            id_v1: row["id"]
          }
        },
        items_import_lambda: ->(items) { CommentTemplate.upsert_all(items, returning: %w[id id_v1]) },
        item_id_finder_lambda: ->(result, row) { result["id_v1"].to_s == row["id"] },
        translation_hash_lambda: ->(item_id, row, locale) {
          title = row["title_#{locale}"]
          message = row["text_#{locale}"]
          return nil if title.blank? && message.blank?

          {
            title: title,
            message: message,
            locale: locale,
            comment_template_id: item_id
          }
        },
        translations_import_lambda: ->(translations) {
          CommentTemplate::Translation.upsert_all(translations)
        }
      )
    end

    def call
      @s3_seed_import_service.call
    end
  end
end
