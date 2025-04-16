# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Unit) do
  describe "Associations" do
    let(:unit) { build(:unit) }

    it do
      expect(unit).to have_many(:foods).inverse_of(:unit)
      expect(unit).to have_many(:nutrients).inverse_of(:unit)
      expect(unit).to have_many(:products).inverse_of(:unit)
    end
  end

  describe "Enums" do
    it { expect(build(:unit)).to be_valid }

    describe "base_unit" do
      it do
        expect(build(:unit)).to define_enum_for(:base_unit)
          .with_values(volume: "ml", mass: "g", energy: "kcal")
          .backed_by_column_of_type(:enum)
      end
    end
  end

  describe "Validations" do
    let(:unit) { build(:unit) }

    it { expect(unit).to be_valid }

    describe "base_unit" do
      it do
        expect(unit).to validate_presence_of(:base_unit)
      end
    end

    describe "factor" do
      it do
        expect(unit).to validate_presence_of(:factor)
        expect(unit).to validate_numericality_of(:factor)
      end
    end

    describe "cannot_change_id_after_persist" do
      let(:unit) { create(:unit, id: "AA") }

      before { unit.update(id: "BB") }

      it { expect(unit.errors.full_messages).to contain_exactly("ID change not allowed") }
    end
  end

  describe "Scopes" do
    describe ".g_and_ml" do
      let!(:unit_mass) { create(:unit, :mass) }
      let!(:unit_energy) { create(:unit, :energy) }
      let!(:unit_volume) { create(:unit, :volume) }
      let!(:unit_kg) { create(:unit, id: "kg") }

      it { expect(described_class.g_and_ml).to contain_exactly(unit_mass, unit_volume) }
    end
  end

  describe "Callbacks" do
    describe "before_destroy" do
      describe "abort_if_not_destroyable" do
        context "when #destroyable? returns true" do
          let!(:unit) { create(:unit) }

          before do
            allow(unit).to receive(:destroyable?).and_return(true)
            unit.destroy
          end

          it { expect(unit.destroy).to be_destroyed }
        end

        context "when #destroyable? returns false" do
          let!(:unit) { create(:unit) }

          before do
            allow(unit).to receive(:destroyable?).and_return(false)
            unit.destroy
          end

          it do
            expect(unit).not_to be_destroyed
            expect(unit.errors[:base]).to contain_exactly("This unit is a base unit and/or has associated models")
          end
        end
      end
    end
  end

  describe "#base_unit?" do
    context "when it is a base unit" do
      let(:unit) { create(:unit, :mass) }

      it { expect(unit.base_unit?).to be(true) }
    end

    context "when it is not a base unit" do
      let(:unit) { create(:unit, :lb) }

      it { expect(unit.base_unit?).to be(false) }
    end
  end
end
