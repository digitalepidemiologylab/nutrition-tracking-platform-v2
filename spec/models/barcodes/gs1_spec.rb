# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Barcodes::GS1) do
  describe ".PREFIX_DATA" do
    it "is sorted for bsearch" do
      expect(described_class::PREFIX_DATA.each_cons(2).all? { |a, b| a.highest < b.lowest }).to be(true)
    end

    it "has lowest/highest valid values" do
      expect(described_class::PREFIX_DATA.each.all? { |prefix_datum| prefix_datum.lowest <= prefix_datum.highest })
        .to be(true)
    end

    it { expect(described_class::PREFIX_DATA.first.lowest).to be >= 0 }
    it { expect(described_class::PREFIX_DATA.last.highest).to be < 1000 }
  end

  describe ".prefix_datum" do
    it "returns nil if the prefix is too short" do
      expect(described_class.prefix_datum(prefix: "5")).to be_nil
      expect(described_class.prefix_datum(prefix: "05")).to be_nil
    end

    it "returns nil if the prefix has no data (reserved by GS1 Global)" do
      expect(described_class.prefix_datum(prefix: "139")).not_to be_nil
      expect(described_class.prefix_datum(prefix: "140")).to be_nil
    end

    it "returns restricted-tagged data for restricted barcodes" do
      expect(described_class.prefix_datum(prefix: "200").tags).to include(:restricted)
      expect(described_class.prefix_datum(prefix: "500").tags).to be_nil
    end
  end

  describe "#calculate_check_digit" do
    it "returns nil if key is nil" do
      expect(described_class.check_digit(code_without_check_digit: nil)).to be_nil
    end

    it "returns nil if key has not the right length" do
      expect(described_class.check_digit(code_without_check_digit: "123")).to be_nil
      expect(described_class.check_digit(code_without_check_digit: "123123123123123123123123123")).to be_nil
    end

    it "returns the check digit if the key is valid" do
      expect(described_class.check_digit(code_without_check_digit: "629104150021")).to eq(3)
      expect(described_class.check_digit(code_without_check_digit: "721032413443")).to eq(2)
      expect(described_class.check_digit(code_without_check_digit: "723489233433")).to eq(9)
    end
  end

  describe "PrefixDatum" do
    describe "#unrestricted_food?" do
      context "when prefix has not tag" do
        it { expect(described_class.prefix_datum(prefix: "900")).to be_unrestricted_food }
      end

      context "when prefix is restricted" do
        it { expect(described_class.prefix_datum(prefix: "250")).not_to be_unrestricted_food }
      end

      context "when prefix is non food" do
        it { expect(described_class.prefix_datum(prefix: "951")).not_to be_unrestricted_food }
      end
    end
  end
end
