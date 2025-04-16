# frozen_string_literal: true

module Users
  class DestroyService < BaseActiveModelService
    attr_reader :user

    validate :validate_participations_count

    def initialize(user:)
      @user = user
    end

    def call
      return false if invalid?

      ActiveRecord::Base.transaction do
        # First, anonymize the user, to keep only anonymized paper_trail versions
        Users::AnonymizeService.new(user: user).call(raise_exception: true)
        associated_models = User
          .reflect_on_all_associations(:has_many)
          .filter_map do |association|
            next if association.options[:through] || association == "PaperTrail::Version"

            association.class_name
          end
        associated_models.each do |model|
          model.constantize.where(user_id: user.id).destroy_all
        end
        # Remove user reference in paper_trail versions as we're going to destroy the user
        PaperTrail::Version.where(user_id: user.id).update_all(user_id: nil)
        PaperTrail::Version.where(item: user).destroy_all
        user.destroy!
      end
    end

    private def validate_participations_count
      return if user.participations.count <= 1

      errors.add(:base, I18n.t("services.users.destroy.errors.participations_count"))
    end
  end
end
