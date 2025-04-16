# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Barcode) do
  describe "Validations" do
    describe "#valid?" do
      context "with ean8" do
        let(:barcode) { build(:barcode) }

        it { expect(barcode).to be_valid }
      end

      context "with ean13" do
        let(:barcode) { build(:barcode, code: "76145513") }

        it { expect(barcode).to be_valid }
      end
    end

    describe "code" do
      let(:barcode) { build(:barcode) }

      it { expect(barcode).to validate_presence_of(:code) }
    end

    describe "#validate_length" do
      let(:barcode) { build(:barcode, code: "12345") }

      it do
        expect(barcode).not_to be_valid
        expect(barcode.errors.full_messages).to include("Barcode has an invalid length")
      end
    end

    describe "#validate_checksum" do
      let(:barcode) { build(:barcode, code: "7611654666870") }

      it do
        expect(barcode).not_to be_valid
        expect(barcode.errors.full_messages).to include("Barcode has an invalid checksum")
      end
    end

    describe "#validate_prefix" do
      let(:barcode) { build(:barcode, code: "9771231233833") }

      it do
        expect(barcode).not_to be_valid
        expect(barcode.errors.full_messages).to include("Barcode has an invalid prefix")
      end
    end
  end

  describe "#company_internal_numbering?" do
    let(:barcode) { build(:barcode, code: "08699152") }

    it { expect(barcode).to be_company_internal_numbering }
  end

  describe "#unrestricted_food?" do
    let(:barcode) { build(:barcode, code: "0409981666043") }

    it { expect(barcode).not_to be_unrestricted_food }
  end
end
