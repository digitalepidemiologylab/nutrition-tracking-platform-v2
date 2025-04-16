# frozen_string_literal: true

module Collab
  class FoodPolicy < BasePolicy
    def index?
      true
    end

    def show?
      true
    end

    def new?
      create?
    end

    def create?
      collaborator.admin? && editable?
    end

    def edit?
      update?
    end

    def update?
      collaborator.admin? && editable?
    end

    def destroy?
      collaborator.admin? && associations_empty? && editable?
    end

    def permitted_attributes
      [
        :annotatable,
        :portion_quantity,
        :fa_ps_ratio,
        :food_list_id,
        {food_set_ids: []},
        {food_nutrients_attributes: %i[id nutrient_id per_hundred _destroy]},
        :kcal_min,
        :kcal_max,
        :segmentable,
        :unit_id
      ] + translated_attributes_for(:name)
    end

    def permitted_sort_attributes
      %w[name food_list unit_id fa_ps_ratio kcal_min kcal_max segmentable annotatable]
    end

    private def associations_empty?
      return true unless record.is_a?(Food)

      has_manies = Food.reflect_on_all_associations(:has_many).map(&:name) - %i[translations]
      has_manies.all? { |association_name| record.public_send(association_name).empty? }
    end

    private def editable?
      return true if record.nil? || record.food_list.nil?

      record.food_list.editable?
    end

    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
end
