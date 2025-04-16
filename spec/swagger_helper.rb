# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rswag::Api.config.openapi_root

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.openapi_specs = {
    "v2/swagger.json" => {
      openapi: "3.0.1",
      info: {
        title: "API V2",
        version: "v2"
      },
      paths: {},
      servers: [
        {
          url: "{defaultProtocol}://{defaultHost}:{defaultPort}",
          variables: {
            defaultProtocol: {
              default: Rails.application.routes.default_url_options[:protocol]
            },
            defaultHost: {
              default: Rails.application.routes.default_url_options[:host]
            },
            defaultPort: {
              default: Rails.application.routes.default_url_options[:port]
            }
          }
        }
      ]
    },

    "collab/v1/swagger.json" => {
      openapi: "3.0.1",
      info: {
        title: "Collab API V1",
        version: "v1"
      },
      paths: {},
      servers: [
        {
          url: "{defaultProtocol}://{defaultHost}:{defaultPort}",
          variables: {
            defaultProtocol: {
              default: Rails.application.routes.default_url_options[:protocol]
            },
            defaultHost: {
              default: Rails.application.routes.default_url_options[:host]
            },
            defaultPort: {
              default: Rails.application.routes.default_url_options[:port]
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :json

  config.after do |example|
    if defined?(response) &&
        response.is_a?(ActionDispatch::TestResponse) &&
        response.body.present? &&
        example&.metadata &&
        example.metadata[:response].present?
      example.metadata[:response][:content] = {
        "application/json" => {
          example: JSON.parse(response.body, symbolize_names: true)
        }
      }
    end
  end
end
