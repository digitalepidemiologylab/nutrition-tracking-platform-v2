# frozen_string_literal: true

require "rails_helper"

describe(Participations::CreateForm) do
  let(:cohort) { create(:cohort) }
  let(:form) { described_class.new(cohort: cohort) }

  describe "Validations" do
    describe "Number" do
      context "when number < 1" do
        before { form.number = 0 }

        it do
          expect(form).not_to be_valid
          expect(form.errors.full_messages).to contain_exactly("Number must be greater than or equal to 1")
        end
      end

      context "when number > 20" do
        before { form.number = 21 }

        it do
          expect(form).not_to be_valid
          expect(form.errors.full_messages).to contain_exactly("Number must be less than or equal to 20")
        end
      end
    end

    describe "validate_participations" do
      let(:valid_participation) { create(:participation) }
      let(:invalid_participation) { build(:participation, key: valid_participation.key) }

      before do
        form.number = 1
        allow(form).to receive(:participations).and_return([invalid_participation])
      end

      it do
        expect(form).not_to be_valid
        expect(form.errors.full_messages).to contain_exactly("Participation: Key has already been taken")
      end
    end
  end

  describe "#save(params)" do
    context "when succesful" do
      it do
        expect { form.save(number: 2) }
          .to change { cohort.participations.count }.by(2)
        expect(form.number).to eq(1)
      end
    end

    context "when failed" do
      let(:valid_participation) { create(:participation) }
      let(:invalid_participation) { build(:participation, key: valid_participation.key) }

      before do
        allow(form).to receive(:participations).and_return([invalid_participation])
      end

      it do
        expect { form.save(number: 1) }
          .not_to change { cohort.participations.count }
        expect(form.errors.full_messages).to contain_exactly("Participation: Key has already been taken")
      end
    end
  end
end
