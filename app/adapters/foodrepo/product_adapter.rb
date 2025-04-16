# frozen_string_literal: true

module Foodrepo
  class ProductAdapter
    include HTTParty

    BASE_URI = ENV.fetch("FOODREPO_API_BASE_URI")

    # HTTParty config
    base_uri(BASE_URI)
    headers({
      "Accept" => "application/json",
      "Accept-Encoding" => "gzip,deflate",
      "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(ENV["FOODREPO_KEY"])
    })

    def initialize(product: nil)
      @product = product
    end

    def fetch_all(barcodes:)
      # 200 is the maximum number of products that can be fetched at once (See FoodRepo API docs)
      response = self.class.get("/products", query: {barcodes: Array(barcodes).join(","), page: {size: 200}})
      found_products = response["data"]
      raise(ApiCallError, response) if response.code != 200

      return [] if found_products.blank?

      found_products.map do |found_product|
        best_product = best_product_by_barcode(barcode: found_product["barcode"], products: found_products)
        next if best_product.blank?

        Foodrepo::Product::ParseService.new(data: best_product).call
      end
    end

    def fetch
      raise(InvalidArgumentError, "Barcode is invalid") unless @product&.barcode

      response = self.class.get("/products", query: {barcodes: @product.barcode, page: {size: 200}})
      best_product = Foodrepo::Product::SelectBestService.new(products: response["data"]).call
      return {} if best_product.blank?

      Foodrepo::Product::ParseService.new(data: best_product).call
    end

    def create
      raise(InvalidArgumentError, "Product is invalid") unless @product

      body = {
        product: {
          barcode: @product.barcode,
          country: "CH",
          images_attributes: tmp_images.map { |image| {data: image} }
        }
      }
      response = self.class.post(
        "/products",
        body: body
      )
      tmp_images.each(&:close!)
      response
    end

    def update(foodrepo_id:)
      raise(InvalidArgumentError, "Product is invalid") unless @product

      body = {
        product: {
          barcode: @product.barcode,
          country: "CH",
          images_attributes: tmp_images.map { |image| {data: image} }
        }
      }
      response = self.class.patch(
        "/products/#{foodrepo_id}",
        body: body
      )
      tmp_images.each(&:close!)
      response
    end

    def updated_after(datetime: 1.month.ago)
      query_params = {
        size: 1000,
        query: {
          range: {
            updated_at: {
              gte: datetime
            }
          }
        },
        sort: :updated_at
      }
      search(query_params)
    end

    private def search(query_params)
      # ElasticSearch Scroll API optimized for _doc order
      query_params[:sort] = :_doc
      body = query_params.to_json
      keep_alive = "1m"
      response = self.class.post(
        "/products/_search?scroll=#{keep_alive}",
        body: body
      )
      raise(ApiCallError, response) if response.code != 200

      total_hits = response.dig("hits", "total")
      hits = response.dig("hits", "hits")
      scroll_id = response["_scroll_id"]
      while hits.length < total_hits
        response = self.class.post(
          "/_search/scroll",
          body: {
            scroll: keep_alive,
            scroll_id: scroll_id
          }.to_json
        )
        raise(ApiCallError, response) if response.code != 200

        hits += response.dig("hits", "hits")
      end

      found_products = hits.filter_map { |hit| hit["_source"] }
      found_products.map do |found_product|
        best_product = best_product_by_barcode(barcode: found_product["barcode"], products: found_products)
        next if best_product.blank?

        Foodrepo::Product::ParseService.new(data: best_product).call
      end
    end

    private def tmp_images
      @tmp_images ||= @product.product_images.map.with_index do |product_image, i|
        tmp_image = Tempfile.new("tmp_image_#{i}", binmode: true)
        product_image.data.download do |chunk|
          tmp_image.write(chunk)
        end
        tmp_image.rewind
        tmp_image
      end
    end

    private def best_product_by_barcode(barcode:, products:)
      products_with_same_barcode = products.select { |product| product["barcode"] == barcode }
      Foodrepo::Product::SelectBestService.new(products: products_with_same_barcode).call
    end

    class InvalidArgumentError < StandardError; end

    class ApiCallError < StandardError; end
  end
end
