# frozen_string_literal: true

FactoryBot.define do
  factory :barcode do
    code do
      # Generate a valid non-restricted and food barcode (randomly one of these countries: FR DE CH IT)
      key = %w[300 400 760 800].sample + Array.new(9) { Random.rand(10).to_s }.join
      "#{key}#{Barcodes::GS1.check_digit(code_without_check_digit: key)}"
    end
  end
end
