# frozen_string_literal: true

FactoryBot.define do
  factory :participation do
    user
    cohort factory: %i[cohort with_food_list]
    associated_at do
      max_ended_at = user&.participations&.maximum(:ended_at)
      max_ended_at ? (max_ended_at + 1.minute) : Time.current
    end
    started_at { associated_at || nil }
    ended_at { started_at ? started_at + 1.week : nil }

    trait :not_associated do
      user { nil }
      associated_at { nil }
      started_at { nil }
      ended_at { nil }
    end

    trait :nil_associated_at do
      after(:create) do |participation, factory|
        participation.update_columns(associated_at: nil, started_at: nil, ended_at: nil)
      end
    end
  end
end
