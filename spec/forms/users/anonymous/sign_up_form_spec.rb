# frozen_string_literal: true

require "rails_helper"

describe(Users::Anonymous::SignUpForm) do
  let(:form) { described_class.new(participation: participation) }

  describe "user" do
    let!(:participation) { create(:participation, :not_associated) }
    let(:user) { form.user }

    it do
      expect(user).to be_a(User)
      expect(user).to be_new_record
      expect(user).to be_anonymous
      expect(user.id).to be_present
    end
  end

  describe "#save" do
    context "when everything valid" do
      let!(:participation) { create(:participation, :not_associated) }

      it do
        expect { form.save! }
          .to change(User, :count).by(1)
          .and(change(participation, :associated_at).from(nil))
          .and(change(participation, :user).from(nil))
        expect(form.errors).to be_empty
      end
    end

    context "with invalid participation" do
      let!(:participation) { create(:participation, :not_associated) }

      context "when participation is blank" do
        before { allow(form).to receive(:participation).and_return(nil) }

        it do
          expect { form.save! }
            .to raise_error(
              ActiveModel::ValidationError,
              "Validation failed: Key doesn't exist"
            )
            .and(not_change(User, :count))
            .and(not_change { participation.reload.user }.from(nil))
        end
      end

      context "when participation is already associated to a user" do
        let!(:participation) { create(:participation) }
        let!(:user) { participation.user }

        it do
          expect { form.save! }
            .to raise_error(
              ActiveModel::ValidationError,
              "Validation failed: Participation is not available"
            )
            .and(not_change(User, :count))
            .and(not_change(participation, :associated_at))
            .and(not_change(participation, :user).from(user))
        end
      end

      context "when associated_at is set" do
        before do
          # Make participation invalid
          allow(participation).to receive(:associated_at).and_return(Time.current)
        end

        it do
          expect { form.save! }
            .to raise_error(
              ActiveModel::ValidationError,
              "Validation failed: Participation is not available"
            )
            .and(not_change(User, :count))
            .and(not_change { participation.reload.user }.from(nil))
        end
      end
    end
  end
end
