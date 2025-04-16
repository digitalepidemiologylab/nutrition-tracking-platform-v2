# frozen_string_literal: true

FactoryBot.define do
  factory :annotation do
    dish
    participation

    after(:build) do |annotation|
      build_intake(annotation)
    end

    trait :with_intakes do
      intakes { build_list(:intake, 2, consumed_at: Time.current) }
    end

    trait :with_dish_image do
      dish factory: %i[dish with_dish_image]
    end

    trait :annotatable do
      dish factory: %i[dish with_dish_image]
      after(:build) do |annotation|
        annotation.send_to_segmentation_service
        annotation.open_annotation
        build_intake(annotation)
      end
    end

    trait :with_annotation_item do
      annotation_items { build_list(:annotation_item, 1, :with_product) }
    end

    trait :with_annotation_items do
      annotation_items { build_list(:annotation_item, 2, :with_product) }
    end

    trait :info_asked do
      after(:build) do |annotation|
        # cannot request annotation if it not saved
        annotation.save!
        annotation.open_annotation unless annotation.annotatable?
        annotation.ask_info
        build_intake(annotation)
      end
    end

    trait :annotated do
      after(:build) do |annotation|
        # cannot request annotation if it not saved
        annotation.save!
        annotation.open_annotation if annotation.may_open_annotation?
        annotation.confirm
        build_intake(annotation)
      end
    end
  end
end

private def build_intake(annotation)
  return if annotation.intakes.any?

  participation = annotation.participation
  consumed_at = if participation&.created_at
    ended_at = (participation.ended_at.nil? || participation.ended_at > 1.hour.from_now) ? Time.current : participation.ended_at
    Faker::Time.between(from: participation&.created_at, to: ended_at)
  else
    Time.current
  end

  annotation.intakes << build(
    :intake,
    annotation: annotation,
    consumed_at: consumed_at
  )
end
