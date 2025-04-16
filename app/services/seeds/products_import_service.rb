# frozen_string_literal: true

require "zip"
require "csv"

module Seeds
  class ProductsImportService
    def initialize
      @s3_client = Aws::S3::Client.new
      @total_imported = 0
      @limit = nil
    end

    def call(limit: nil)
      @limit = limit
      zip_tempfile = Tempfile.new(%W[products .zip])
      csv_tempfile = Tempfile.new(%W[products .csv])
      get_zip(zip_tempfile)
      extract_csv(zip_tempfile, csv_tempfile)
      get_products(csv_tempfile)
    end

    private def get_zip(zip_tempfile)
      @s3_client.get_object(
        response_target: zip_tempfile.path,
        bucket: "myfoodrepo2-db-seeds",
        key: "myfoodrepo1_export/products_latest.zip"
      )
    end

    private def extract_csv(zip_tempfile, csv_tempfile)
      Zip::File.open(zip_tempfile.path) do |zip|
        zip.extract("products.csv", csv_tempfile.path) { true }
      end
    end

    private def get_products(csv_tempfile)
      # 200 is the maximum number of products that can be fetched at once (See FoodRepo API docs)
      CSV.foreach(csv_tempfile, headers: true).each_slice(200) do |rows|
        barcodes = rows.pluck("barcode")
        adapter = Foodrepo::ProductAdapter.new
        products_data = adapter.fetch_all(barcodes: barcodes)
        save_products(products_data)
        break if @limit && @total_imported >= @limit
      end
    end

    private def save_products(products_data)
      products_data.each do |product_data|
        status = product_data.delete(:status)
        next if status != "complete"

        product_attributes = product_data[:data]
        product = ::Product.find_or_initialize_by(barcode: product_data[:barcode])
        next if product.persisted?

        product.mark_complete! if product.may_mark_complete?
        product.update!(product_attributes)
        @total_imported += 1
        break if @limit && @total_imported >= @limit
      end
    end
  end
end
