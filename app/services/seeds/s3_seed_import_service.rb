# frozen_string_literal: true

require "zip"
require "csv"

module Seeds
  class S3SeedImportService
    def initialize(args = {})
      @collection_name = args[:collection_name]
      @item_hash_lambda = args[:item_hash_lambda]
      @items_import_lambda = args[:items_import_lambda]
      @item_id_finder_lambda = args[:item_id_finder_lambda]
      @translation_hash_lambda = args[:translation_hash_lambda]
      @translations_import_lambda = args[:translations_import_lambda]
      @s3_client = Aws::S3::Client.new
    end

    def call(limit: nil)
      zip_tempfile = Tempfile.new(%W[#{@collection_name} .zip])
      populate_zip_tempfile(zip_tempfile)

      csv_tempfile = Tempfile.new(%W[#{@collection_name} .csv])
      populate_csv_tempfile(zip_tempfile, csv_tempfile)

      save_items(csv_tempfile, limit: limit)
    ensure
      zip_tempfile&.close!
      csv_tempfile&.close!
    end

    private def populate_zip_tempfile(zip_tempfile)
      @s3_client.get_object(
        response_target: zip_tempfile.path,
        bucket: "myfoodrepo2-db-seeds",
        key: "myfoodrepo1_export/#{@collection_name}_latest.zip"
      )
    end

    private def populate_csv_tempfile(zip_tempfile, csv_tempfile)
      Zip::File.open(zip_tempfile.path) do |zip|
        zip.extract("#{@collection_name}.csv", csv_tempfile.path) { true }
      end
    end

    private def save_items(csv_tempfile, limit: nil)
      count = 0
      limit = limit.to_i
      CSV.foreach(csv_tempfile, headers: true).each_slice(1000) do |rows|
        break if limit.positive? && count >= limit

        items = rows.filter_map { |row| @item_hash_lambda.call(row) }
        next if items.blank?

        import_result = @items_import_lambda.call(items)
        count += items.size

        if @item_id_finder_lambda && @translation_hash_lambda && @translations_import_lambda
          result_array = import_result.to_a
          translations = []
          I18n.available_locales.each do |locale|
            translations += rows.filter_map { |row|
              item_id = result_array.find { |result| @item_id_finder_lambda.call(result, row) }["id"]
              @translation_hash_lambda.call(item_id, row, locale)
            }
          end
          @translations_import_lambda.call(translations) if translations.present?
        end
      end
    end
  end
end
