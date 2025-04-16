# frozen_string_literal: true

module Collab
  class ApiDocumentationsController < BaseController
    def api_v2
      authorize(:api_documentation, :api_v2?)
      @breadcrumbs = [{text: t("layouts.collab.api_v2_documentation"), url: api_v2_collab_api_documentation_path}]
    end

    def collab_api_v1
      authorize(:api_documentation, :collab_api_v1?)
      @breadcrumbs = [{text: t("layouts.collab.api_collab_v1_documentation"), url: collab_api_v1_collab_api_documentation_path}]
    end
  end
end
