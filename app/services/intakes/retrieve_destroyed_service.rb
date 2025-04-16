# frozen_string_literal: true

module Intakes
  class RetrieveDestroyedService
    def initialize(params:, user: nil)
      @params = params
      @user = user
    end

    def call
      destroyed_intakes = all_destroyed_intakes
      destroyed_intakes = filter_by_user(destroyed_intakes)
      filter_by_updated_at(destroyed_intakes)
    end

    private def all_destroyed_intakes
      PaperTrail::Version.where(item_type: "Intake", event: "destroy")
    end

    private def filter_by_user(destroyed_intakes)
      return destroyed_intakes unless @user

      destroyed_intakes.where(user_id: @user.id)
    end

    private def filter_by_updated_at(destroyed_intakes)
      updated_at_gt = @params.dig(:filter, :updated_at_gt)
      return destroyed_intakes unless updated_at_gt

      begin
        destroyed_intakes
          .where(
            "created_at > ?",
            @params.dig(:filter, :updated_at_gt).to_datetime
          )
      rescue Date::Error => e
        raise BaseQuery::BadFilterParam, e.message
      end
    end
  end
end
