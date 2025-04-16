# frozen_string_literal: true

module Collab
  class FoodListPolicy < BasePolicy
    def index?
      true
    end

    def show?
      true
    end

    def edit?
      update?
    end

    def update?
      return true if record.nil?

      record.editable? && collaborator.admin?
    end

    def destroy?
      return true if record.nil?

      record.editable? && associations_empty? && collaborator.admin?
    end

    def permitted_attributes
      return [] if record.new_record? || !collaborator.admin?

      %i[name metadata_data source version country_id editable]
    end

    def permitted_sort_attributes
      %w[country name]
    end

    private def associations_empty?
      return true unless record.is_a?(FoodList)

      has_manies = FoodList.reflect_on_all_associations(:has_many).map(&:name)
      has_manies.all? { |association_name| record.public_send(association_name).empty? }
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope
            .joins(:cohort_food_lists)
            .where(cohort_food_lists: {cohort: CohortPolicy::Scope.new(collaborator, Cohort).resolve})
        end
      end
    end
  end
end
