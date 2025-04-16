# frozen_string_literal: true

require "webmock/rspec"

RSpec.configure do |config|
  known_foodrepo_products = {
    %w[5449000009500] => "coca_cola",
    %w[5941021017118] => "dark_chocolate",
    %w[4001686330135] => "haribo_apples",
    %w[7610848337010] => "sliced_mango"
  }

  config.before do
    # No network activity allowed but we still allow download
    # of updated chromedriver if needed (useful for system tests in docker)
    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: [
        "chromedriver.storage.googleapis.com",
        ENV["SELENIUM_REMOTE_HOST"]
      ].compact
    )

    # FoodRepo : fetch product by barcode
    request_barcodes = nil
    stub_request(:get, "#{ENV.fetch("FOODREPO_API_BASE_URI")}/products")
      .with(query: hash_including("barcodes"))
      .to_return do |request|
        # Test for wrong API key
        request_auth = request.headers["Authorization"]
        request_barcodes = CGI.parse(request.uri.query)["barcodes"]
        if request_auth != ActionController::HttpAuthentication::Token.encode_credentials(ENV["FOODREPO_KEY"])
          {status: 401}
        elsif request_barcodes.first.split(",").length > 1
          {
            status: 200,
            headers: {
              "content-type" => ["application/json; charset=utf-8"]
            },
            body: Rails.root.join("spec/fixtures/files/webmock/foodrepo/products/multiple.json").read
          }
        else
          product = known_foodrepo_products[request_barcodes] || "not_found"
          {
            status: 200,
            headers: {
              "content-type" => ["application/json; charset=utf-8"]
            },
            body: Rails.root.join("spec/fixtures/files/webmock/foodrepo/products/#{product}.json").read
          }
        end
      end

    # FoodRepo : create product
    headers = {"Content-Type" => /multipart\/form-data/}
    match_multipart_body = ->(request) do
      request.body.force_encoding("BINARY")
      request.body.include?("Content-Type: application/octet-stream")
    end

    stub_request(:post, "#{ENV.fetch("FOODREPO_API_BASE_URI")}/products")
      .with(headers: headers, &match_multipart_body)
      .to_return do |_request|
        {
          status: 201,
          headers: {
            "content-type" => ["application/json; charset=utf-8"]
          },
          body: {
            "status" => "created",
            "meta" => {
              "api_version" => "3.03",
              "generated_in" => 461
            }
          }.to_json
        }
      end

    # FoodRepo : update product
    headers = {"Content-Type" => /multipart\/form-data/}
    match_multipart_body = ->(request) do
      request.body.force_encoding("BINARY")
      request.body.include?("Content-Type: application/octet-stream")
    end

    stub_request(:patch, %r{#{Regexp.escape("#{ENV.fetch("FOODREPO_API_BASE_URI")}/products/")}\d+})
      .with(headers: headers, &match_multipart_body)
      .to_return do |_request|
        {
          status: 204,
          headers: {
            "content-type" => ["application/json; charset=utf-8"]
          }
        }
      end

    # FoodRepo : search products
    # First scroll batch
    stub_request(:post, "#{ENV.fetch("FOODREPO_API_BASE_URI")}/products/_search?scroll=1m")
      .to_return do |_request|
        {
          status: 200,
          headers: {
            "content-type" => ["application/json; charset=utf-8"]
          },
          body: Rails.root.join("spec/fixtures/files/webmock/foodrepo/products/search_with_scroll_batch_1.json").read
        }
      end
    # Second scroll batch
    stub_request(:post, "#{ENV.fetch("FOODREPO_API_BASE_URI")}/_search/scroll")
      .to_return do |_request|
        {
          status: 200,
          headers: {
            "content-type" => ["application/json; charset=utf-8"]
          },
          body: Rails.root.join("spec/fixtures/files/webmock/foodrepo/products/search_with_scroll_batch_2.json").read
        }
      end

    # Aicrowd task creation
    stub_request(:post, %r{#{Regexp.escape("#{ENV.fetch("AICROWD_API_BASE_URI")}/enqueue")}})
      .to_return(
        status: 200,
        body: file_fixture("webmock/aicrowd/task_created.json").read
      )

    # Aicrowd task reading
    stub_request(:get, %r{#{Regexp.escape("#{ENV.fetch("AICROWD_API_BASE_URI")}/status")}})
      .to_return(
        status: 200,
        body: file_fixture("webmock/aicrowd/task_succeeded.json").read
      )
  end

  config.around do |example|
    # Pwned
    # 5BAA6: pwned
    # 37D5B: not pwned
    pwned_range = example.metadata[:pwned_range]
    if pwned_range
      File.open(File.expand_path("../fixtures/files/pwned/#{pwned_range}.txt", __dir__)) do |body|
        uri = %r{https://api.pwnedpasswords.com/range/.+}
        stub_request(:get, uri).to_return(status: 200, body: body)
        example.run
      end
    else
      stub_request(:get, %r{https://api.pwnedpasswords.com/range/.+})
        .to_return(status: 200)
      example.run
    end
  end
end
