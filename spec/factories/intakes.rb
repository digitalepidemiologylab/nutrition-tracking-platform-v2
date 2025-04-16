# frozen_string_literal: true

FactoryBot.define do
  factory :intake do
    annotation
    consumed_at do |intake|
      if intake.annotation&.participation&.created_at
        participation = intake.annotation.participation
        ended_at = (participation.ended_at.nil? || participation.ended_at > 1.hour.from_now) ? Time.current : participation.ended_at
        Faker::Time.between(
          from: intake.annotation.participation.created_at,
          to: ended_at
        )
      elsif intake.annotation&.created_at
        Faker::Time.between(from: intake.annotation.created_at, to: Time.current)
      else
        Time.current
      end
    end
    timezone { ActiveSupport::TimeZone.all.sample.tzinfo.name }
  end
end
