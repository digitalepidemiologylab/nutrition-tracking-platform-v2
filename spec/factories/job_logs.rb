# frozen_string_literal: true

FactoryBot.define do
  factory :job_log do
    job_id { Faker::Internet.uuid }
    job_name { [Faker::Company.industry.classify, Faker::Company.industry.classify].join("::") }
    logs { "First line error\nSecond line error" }
  end
end
