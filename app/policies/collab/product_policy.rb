# frozen_string_literal: true

module Collab
  class ProductPolicy < BasePolicy
    def index?
      true
    end

    def show?
      index?
    end

    def permitted_sort_attributes
      %w[name status barcode source unit_id fetched_at]
    end

    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
end
