# frozen_string_literal: true

module Api
  module V2
    module Participations
      class ParticipatePolicy < BasePolicy
        def create?
          record.present? &&
            record.associated_at.blank? &&
            (record.user.blank? || record.user == user)
        end
      end
    end
  end
end
