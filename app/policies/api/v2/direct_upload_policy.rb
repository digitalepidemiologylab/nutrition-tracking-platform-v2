# frozen_string_literal: true

module Api
  module V2
    class DirectUploadPolicy < BasePolicy
      def create?
        true
      end

      def permitted_attributes
        [
          :type,
          attributes: [
            :filename,
            :byte_size,
            :checksum,
            :content_type
          ]
        ]
      end
    end
  end
end
