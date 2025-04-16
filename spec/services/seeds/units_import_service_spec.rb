# frozen_string_literal: true

require "rails_helper"

describe(Seeds::UnitsImportService) do
  let(:importer) { described_class.new }

  describe "#call" do
    it do
      expect { importer.call }
        .to change(Unit, :count).by(20)
      expect(Unit.pluck(:id)).to eq(
        [
          "μg", "mg", "g", "kg", "oz", "lb", "μg RAE", "α-TAE", "ml", "cl", "dl", "l", "fl oz", "gallon", "cup", "tsp",
          "tbsp", "kJ", "kcal", "bread_unit"
        ]
      )
    end
  end
end
