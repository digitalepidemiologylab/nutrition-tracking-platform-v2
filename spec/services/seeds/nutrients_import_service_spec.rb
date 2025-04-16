# frozen_string_literal: true

require "rails_helper"

describe(Seeds::NutrientsImportService) do
  describe "#call" do
    let!(:country) { create(:country, :ch) }
    let!(:unit_mass) { create(:unit, :mass) }
    let!(:unit_volume) { create(:unit, id: :mg, factor: 0.001) }
    let(:importer) { described_class.new }
    let(:s3_client) {
      Aws::S3::Client.new(
        stub_responses: {
          get_object: {body: File.read("spec/support/data/myfoodrepo1_export/subset_nutrients.zip")}
        }
      )
    }

    before { allow(Aws::S3::Client).to receive(:new).and_return(s3_client) }

    it do
      expect { importer.call }.to change(Nutrient, :count).by(15)
        .and(change(Nutrient::Translation, :count).by(45))
    end
  end

  describe ".clean_cname" do
    it { expect(described_class.clean_cname("caffeine")).to eq("caffeine") }
    it { expect(described_class.clean_cname("fa_4:0")).to eq("fa_4_0") }
    it { expect(described_class.clean_cname("fa_22:6_n-3")).to eq("fa_22_6_n_3") }
    it { expect(described_class.clean_cname("asparaginsäure")).to eq("asparaginsaure") }
  end
end
