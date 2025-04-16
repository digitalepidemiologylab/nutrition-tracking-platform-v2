# frozen_string_literal: true

FactoryBot.define do
  factory :comment_template do
    trait :with_title do
      I18n.available_locales.each do |locale|
        send("title_#{locale}") { Faker::Lorem.sentence }
      end
    end

    trait :with_message do
      I18n.available_locales.each do |locale|
        send("message_#{locale}") { Faker::Lorem.paragraph }
      end
    end

    trait :valid do
      with_title
      with_message
    end
  end
end
