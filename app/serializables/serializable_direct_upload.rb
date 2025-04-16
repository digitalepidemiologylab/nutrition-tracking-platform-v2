# frozen_string_literal: true

class SerializableDirectUpload < JSONAPI::Serializable::Resource
  type "direct_uploads"

  id { @object.signed_id }

  attribute :url do
    @object.service_url_for_direct_upload(expires_in: 2.days)
  end

  attribute :headers do
    @object.service_headers_for_direct_upload
  end
end
