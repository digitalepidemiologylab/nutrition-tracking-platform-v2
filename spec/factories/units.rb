# frozen_string_literal: true

FactoryBot.define do
  factory :unit do
    id { "g" }
    base_unit { Unit.base_units.fetch(:mass) }
    factor do
      next 1 if id.in?(%w[g ml kcal])

      Faker::Number.decimal
    end

    # Try to find and load existing instance before creating one
    to_create do |instance|
      unit = Unit.find_by(id: instance.id) ||
        Unit.create!(
          id: instance.id,
          base_unit: instance.base_unit,
          factor: instance.factor
        )
      instance.attributes = unit.attributes
      instance.instance_variable_set(:@new_record, false)
    end

    trait :mass do
      id { "g" }
      factor { 1 }
      base_unit { Unit.base_units.fetch(:mass) }
    end

    trait :volume do
      id { "ml" }
      factor { 1 }
      base_unit { Unit.base_units.fetch(:volume) }
    end

    trait :energy do
      id { "kcal" }
      factor { 1 }
      base_unit { Unit.base_units.fetch(:energy) }
    end

    trait :lb do
      id { "lb" }
      factor { 453.592 }
      base_unit { Unit.base_units.fetch(:mass) }
    end
  end
end
