# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Barcodes::NormalizerService) do
  describe "#call" do
    context "with ean8" do
      let(:barcode) { "76145513" }

      it { expect(described_class.new(barcode).call).to eq("76145513") }
    end

    context "with unnormalized ean8" do
      let(:barcode) { "  76/14-55.13" }

      it { expect(described_class.new(barcode).call).to eq("76145513") }
    end

    context "with ean13" do
      let(:barcode) { "7611654666875" }

      it { expect(described_class.new(barcode).call).to eq("7611654666875") }
    end

    context "with unnormalized ean13" do
      let(:barcode) { "  761-165-466-687-5." }

      it { expect(described_class.new(barcode).call).to eq("7611654666875") }
    end

    context "with UPC-A" do
      let(:barcode) { " 0123 45678905" }

      it { expect(described_class.new(barcode).call).to eq("0012345678905") }
    end

    context "with ean14" do
      let(:barcode) { "07611654666875" }

      it { expect(described_class.new(barcode).call).to eq("7611654666875") }
    end

    context "with unsupported ean14" do
      let(:barcode) { "17611654666872" }

      it { expect(described_class.new(barcode).call).to be_nil }
    end

    context "with invalid type" do
      let(:barcode) { "12345" }

      it { expect(described_class.new(barcode).call).to be_nil }
    end

    context "with text" do
      let(:barcode) { "bad data here" }

      it { expect(described_class.new(barcode).call).to be_nil }
    end
  end
end
