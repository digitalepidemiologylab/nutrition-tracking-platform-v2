# frozen_string_literal: true

module BaseImage
  extend ActiveSupport::Concern
  include PgSearch::Model

  included do
    has_one_attached :data do |attachable|
      attachable.variant(:thumb, resize_to_fill: [150, 150])
    end

    validate :data_is_image, :attachement_is_unique
  end

  def data=(value)
    if value.is_a?(String)
      # Internaly Rails uses `find_signed!` instead of `find_signed` when the value is a string,
      # but we don't want to raise an error because we want to use the validations to show the errors.
      super(ActiveStorage::Blob.find_signed(value))
    else
      super
    end
  end

  private def data_is_image
    return if data.blob&.content_type&.start_with?("image/")

    data.purge
    errors.add(:data, I18n.t("activerecord.errors.models.base_image.attributes.data.not_image"))
  end

  private def attachement_is_unique
    return if data.attachment&.persisted? || data.attachment&.blob_id.nil? || !ActiveStorage::Attachment.exists?(blob_id: data.attachment.blob_id)

    data.purge
    errors.add(:data, :taken)
  end
end
