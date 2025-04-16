# frozen_string_literal: true

module Collab
  class ApiDocumentationPolicy < BasePolicy
    def api_v2?
      true
    end

    def collab_api_v1?
      api_v2?
    end
  end
end
