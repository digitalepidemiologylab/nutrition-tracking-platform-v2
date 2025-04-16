# frozen_string_literal: true

require "rails_helper"

RSpec.describe(BarcodeValidator) do
  let(:barcode_bearer_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :barcode

      validates :barcode, barcode: true

      def self.name
        "BarcodeBearer"
      end
    end
  end
  let(:instance) { barcode_bearer_class.new }

  context "when barcode is valid" do
    before { instance.barcode = build(:barcode).code }

    it { expect(instance).to be_valid }
  end

  context "when barcode is not valid" do
    before { instance.barcode = "aWrongBarcode" }

    it do
      expect(instance).not_to be_valid
      expect(instance.errors.full_messages)
        .to include("Barcode must be a valid EAN or UPC barcode")
    end
  end
end
