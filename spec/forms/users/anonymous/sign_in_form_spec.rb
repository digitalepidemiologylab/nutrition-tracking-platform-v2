# frozen_string_literal: true

require "rails_helper"

describe(Users::Anonymous::SignInForm) do
  let(:form) { described_class.new(participation: participation) }

  describe "#initialize(participation:)" do
    let!(:participation) { create(:participation, :nil_associated_at) }

    it do
      expect(form.user).to be_a(User)
      expect(form.user).to be_persisted
      expect(form.user).not_to be_anonymous
      expect(form.token).to be_nil
    end
  end

  describe "#save!", :freeze_time do
    context "with valid params" do
      let!(:participation) { create(:participation, :nil_associated_at) }
      let(:user) { participation.user }

      it do
        expect { form.save! }
          .to not_change(User, :count)
          .and(change { participation.reload.associated_at }.from(nil).to(Time.current))
          .and(not_change(participation, :user).from(user))
          .and(change { user.reload.tokens }.from({}))
          .and(change(form, :token).from(nil))
        expect(form.errors).to be_empty
      end
    end

    context "with invalid participation" do
      context "when participation is nil" do
        let!(:participation) { nil }

        it do
          expect { form.save! }
            .to raise_error(ActiveModel::ValidationError, "Validation failed: Key doesn't exist")
        end
      end

      context "when participation is already associated to a user" do
        let!(:participation) { create(:participation) }
        let!(:user) { participation.user }

        it do
          expect { form.save! }
            .to raise_error(ActiveModel::ValidationError, "Validation failed: Participation is not available")
        end
      end
    end
  end
end
