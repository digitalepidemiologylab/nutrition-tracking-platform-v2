# frozen_string_literal: true

# This script exports all the annotation items for a cohort to a CSV file.
# The CSV file is saved in the current directory.
# The script takes two arguments, the environment (local, staging or production) and the cohort ID
#
# The script requires the following environment variables:
# - MFR_UID
# - MFR_CLIENT
# - MFR_ACCESS_TOKEN
#
# The script also requires the following gem:
# - json-api-vanilla (`gem install json-api-vanilla`)
#
# Example:
#
# `export MFR_UID=your@email.com`
# `export MFR_CLIENT=your-client-id`
# `export MFR_ACCESS_TOKEN=your-access-token`
# `ruby ./export_cohort_annotation_items.rb local 3e386679-5e39-418c-bb92-14520ceb3d01`

require "csv"
require "time"
require "json-api-vanilla"
require "net/http"

class MyFoodRepoService
  LOCAL_HOST = "mfr.localhost"
  STAGING_HOST = "staging-v2.myfoodrepo.org"
  PRODUCTION_HOST = "v2.myfoodrepo.org"

  def initialize(host:, uid:, client:, access_token:)
    @uid = ENV["MFR_UID"]
    @client = ENV["MFR_CLIENT"]
    @access_token = ENV["MFR_ACCESS_TOKEN"]

    if @uid.nil? || @client.nil? || @access_token.nil?
      raise MissingEnvVarError, "MFR_UID, MFR_CLIENT or MFR_ACCESS_TOKEN envrionment variable is missing"
    end

    @http = Net::HTTP.new(host, 443)
    @http.ca_file = `echo "$(mkcert -CAROOT)/rootCA.pem"`.strip if host == LOCAL_HOST
    @http.use_ssl = true
  end

  def participations(cohort_id:, page:)
    response = send_request(
      path: "/collab/api/v1/cohorts/#{cohort_id}/participations", params: {page: page, items: 100}
    )
    doc = JSON::Api::Vanilla.parse(response.body)
    return doc.data, extract_next_page(doc)
  end

  def annotations(participation_id:, page:)
    response = send_request(
      path: "/collab/api/v1/participations/#{participation_id}/annotations",
      params: {
        page: page,
        items: 10,
        include: "dish,dish.dish_image,intakes,comments,annotation_items,annotation_items.food," \
          "annotation_items.food.food_nutrients,annotation_items.product,annotation_items.product.product_nutrients"
      }
    )
    doc = JSON::Api::Vanilla.parse(response.body)
    return doc.data, extract_next_page(doc)
  end

  def nutrient_ids
    page = 1
    nutrient_ids = []

    until page.nil?
      response = send_request(path: "/collab/api/v1/nutrients", params: {page: page, items: 250})
      doc = JSON::Api::Vanilla.parse(response.body)
      nutrient_ids += doc.data.map(&:id)
      page = extract_next_page(doc)
    end

    nutrient_ids
  end

  private def send_request(method = :get, path:, params: {})
    case method
    when :get
      full_path = [path, URI.encode_www_form(params)].join("?")
      request = Net::HTTP::Get.new(full_path)
    else
      raise NotImplementedError, "🛑 Method #{method} is not implemented in send_request method"
    end

    puts "✉️ Sending request to #{request.path}"

    request["content-type"] = "application/json"
    request["accept"] = "application/json"
    request["uid"] = @uid
    request["client"] = @client
    request["access-token"] = @access_token

    start_time = Time.now.utc
    response = @http.request(request)
    request_time = Time.now.utc - start_time
    puts "⏱️ HTTP request time: #{request_time} seconds"

    unless response.is_a?(Net::HTTPSuccess)
      raise MyFoodRepoServiceResponseError,
        "🛑 MyFoodRepoService reponse error: #{response.code} - #{response.message}"
    end

    response
  end

  private def extract_next_page(doc)
    data = doc.data
    doc.meta[data]["next"]
  end

  class MissingEnvVarError < StandardError; end

  class MyFoodRepoServiceResponseError < StandardError; end

  class NotImplementedError < StandardError; end
end

class ExportCohortAnnotationsService
  def initialize(myfoodrepo_service:, cohort_id:)
    @myfoodrepo_service = myfoodrepo_service
    @cohort_id = cohort_id
  end

  def call
    start_time = Time.now.utc

    timestamp = Time.now.utc.iso8601.delete("-:.")
    csv_filename = "cohort_#{@cohort_id}_annotation_items_#{timestamp}.csv"
    csv = CSV.open(csv_filename, "w")

    nutrient_ids = @myfoodrepo_service.nutrient_ids
    headers = %w[
      intake_id
      annotation_id
      participation_key
      consumed_at
      timezone
      annotation_status
      food_id
      food_name
      product_id
      product_barcode
      product_name
      consumed_quantity
      consumed_unit
    ]
    headers += nutrient_ids
    headers << "comments"
    csv << headers

    participations_page = 1
    until participations_page.nil?
      participations, participations_page = @myfoodrepo_service.participations(
        cohort_id: @cohort_id, page: participations_page
      )
      participations.each do |participation|
        puts "📂 Participation #{participation.key} #{[participation.started_at, participation.ended_at].join(" – ")}"

        annotations_page = 1
        until annotations_page.nil?
          annotations, annotations_page = @myfoodrepo_service.annotations(
            participation_id: participation.id, page: annotations_page
          )
          annotations.each do |annotation|
            puts "📝 Processing annotation #{annotation.id}"

            annotation.intakes.each do |intake|
              annotation.annotation_items.each do |annotation_item|
                # We use `demodulize` because if `food` is empty, `json-api-vanilla` returns not null... but an empty
                # object. So we need to demodulize the class to check if `food` or `product` is present.
                # See https://github.com/trainline/json-api-vanilla/issues/14
                if demodulize(annotation_item.food.class) == "Foods"
                  food_id = annotation_item.food.id
                  food_name = annotation_item.food.name
                elsif demodulize(annotation_item.product.class) == "Products"
                  product_id = annotation_item.product.id
                  product_barcode = annotation_item.product.barcode
                  product_name = annotation_item.product.name
                end

                values = [
                  intake.id,
                  annotation.id,
                  participation.key,
                  intake.consumed_at,
                  intake.timezone,
                  annotation.status,
                  food_id,
                  food_name,
                  product_id,
                  product_barcode,
                  product_name,
                  annotation_item.consumed_quantity,
                  annotation_item.consumed_unit_id
                ]

                nutrient_ids.each do |nutrient_id|
                  nutrient_value = nil

                  if !food_id.nil?
                    food_nutrient = annotation_item.food.food_nutrients.find { |fn| fn.nutrient.id == nutrient_id }

                    if food_nutrient
                      nutrient_value = annotation_item.consumed_quantity * food_nutrient.per_hundred / 100
                    end
                  elsif !product_id.nil?
                    product_nutrient = annotation_item.product.product_nutrients
                      .find { |pn| pn.nutrient.id == nutrient_id }

                    if product_nutrient
                      nutrient_value = annotation_item.consumed_quantity * product_nutrient.per_hundred / 100
                    end
                  end

                  values << nutrient_value&.round(2)
                end

                values << annotation.comments.map do |comment|
                  is_collaborator = demodulize(comment.collaborator.class) == "Collaborators"
                  "#{is_collaborator ? "Collaborator" : "User"}: #{comment.message} – #{comment.created_at}"
                end.join("\n")

                csv << values
              end
            end
          end
        end
      end
    end

    csv.close

    request_time = Time.now.utc - start_time
    puts "⏱️ Total script time: #{request_time} seconds"
  end

  private def demodulize(klass)
    path = klass.name
    i = path.rindex("::")
    i ? path[(i + 2)..] : path
  end
end

host = case ARGV[0]
when "local"
  puts "🌐 Local environment"
  MyFoodRepoService::LOCAL_HOST
when "staging"
  puts "🌐 Staging environment"
  MyFoodRepoService::STAGING_HOST
when "production"
  puts "🌐 Production environment"
  MyFoodRepoService::PRODUCTION_HOST
else
  puts "🛑 Missing environment argument (local, staging or production)"
  exit 1
end

cohort_id = ARGV[1]

if cohort_id.nil?
  puts "🛑 Missing cohort ID argument"
  exit 1
end

myfoodrepo_service = MyFoodRepoService.new(
  host: host,
  uid: ENV["MFR_UID"],
  client: ENV["MFR_CLIENT"],
  access_token: ENV["MFR_ACCESS_TOKEN"]
)
ExportCohortAnnotationsService.new(myfoodrepo_service: myfoodrepo_service, cohort_id: cohort_id).call
