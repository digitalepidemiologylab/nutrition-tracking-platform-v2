# frozen_string_literal: true

# Inspired by https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/direct_uploads_controller.rb
module Api
  module V2
    class DirectUploadsController < BaseController
      include ActiveStorage::SetCurrent

      def create
        authorize(:direct_upload)
        blob = ActiveStorage::Blob.create_before_direct_upload!(
          **permitted_attributes(:direct_upload)[:attributes].to_h.symbolize_keys
        )
        render jsonapi: blob, class: {"ActiveStorage::Blob": SerializableDirectUpload}, status: :ok
      end
    end
  end
end
