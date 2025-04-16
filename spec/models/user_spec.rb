# frozen_string_literal: true

require "rails_helper"

RSpec.describe(User) do
  it_behaves_like "has_note"
  it_behaves_like "has_password_not_pwned"

  describe "Associations" do
    let(:user) { build(:user) }

    it do
      expect(user).to have_many(:dishes).inverse_of(:user).dependent(:destroy)
      expect(user).to have_many(:annotations).through(:dishes)
      expect(user).to have_many(:intakes).through(:annotations)
      expect(user).to have_many(:participations).inverse_of(:user).dependent(:destroy)
      expect(user).to have_many(:cohorts).through(:participations)
      expect(user).to have_many(:push_tokens).inverse_of(:user).dependent(:destroy)
      expect(user).to have_many(:comments).inverse_of(:user).dependent(:destroy)
    end
  end

  describe "Validations" do
    describe "email" do
      let(:user) { build(:user) }

      # Uniqueness validation cannot be tested as it always report the scope to :provider
      it { expect(user).to validate_presence_of(:email) }
    end

    describe "password" do
      let(:user) { build(:user, password: password) }

      context "when password has been pwned", pwned_range: "5BAA6" do
        let(:password) { "password" }

        it do
          expect(user).not_to be_valid
          expect(user.errors.full_messages).to contain_exactly("Password has previously appeared in a data breach and should not be used")
        end
      end

      context "when password has not been pwned", pwned_range: "37D5B" do
        let(:password) { "t3hb3stpa55w0rd" }

        it { expect(user).to be_valid }
      end
    end

    describe "validate_anonymous_user_attributes" do
      context "when anonymous user" do
        let!(:user) { create(:user, :anonymous) }

        context "when updated to non anonymous" do
          before { user.anonymous = false }

          context "when updating both email and password" do
            before do
              user.email = "new_email@myfoodrepo.org"
              user.password = "new_password"
              user.password_confirmation = "new_password"
            end

            it { expect(user).to be_valid }
          end

          context "when updating only email" do
            before { user.email = "new_email@myfoodrepo.org" }

            it do
              expect(user).not_to be_valid
              expect(user.errors.full_messages).to contain_exactly("Both email and password must be updated")
            end
          end
        end

        context "when not updated to non anonymous" do
          context "when updating only email" do
            before { user.email = "new_email@myfoodrepo.org" }

            it { expect(user).to be_valid }
          end
        end
      end

      context "when non-anonymous" do
        let!(:user) { create(:user) }

        context "when updating only email" do
          before { user.email = "new_email@myfoodrepo.org" }

          it { expect(user).to be_valid }
        end
      end
    end
  end

  describe "Versioning", :freeze_time do
    let(:user) { create(:user) }

    with_versioning do
      it do
        PaperTrail.request(whodunnit: "John Doe") do
          expect(user).to be_versioned
          user.update!(note: "a note")
          user.update!(note: "an updated note")
          user.update!(note: "a corrected note")
          expect(user).to have_a_version_with(note: "a note")
          expect(user).to have_a_version_with(note: "an updated note")
          expect(user).not_to have_a_version_with(note: "a corrected note")

          user.update!(updated_at: 1.day.from_now)
          expect(user).not_to have_a_version_with(updated_at: Time.current)
        end
      end
    end
  end

  describe "#current_participation" do
    let!(:user) { create(:user) }
    let!(:participation_1) { create(:participation, user: user, started_at: 10.days.ago, ended_at: 8.days.ago) }
    let!(:participation_2) { create(:participation, user: user, started_at: 4.days.ago, ended_at: ended_at) }
    let!(:participation_3) { create(:participation, user: user, started_at: 7.days.ago, ended_at: 5.days.ago) }

    context "when ended_at is set" do
      let(:ended_at) { 1.day.from_now }

      it { expect(user.current_participation).to eq(participation_2) }
    end

    context "when ended_at is not set" do
      let(:ended_at) { nil }

      it { expect(user.current_participation).to eq(participation_2) }
    end
  end

  describe "#email_or_id" do
    let(:user) { create(:user, anonymous: anonymous) }

    context "when anonymous" do
      let(:anonymous) { true }

      it { expect(user.email_or_id).to eq(user.id) }
    end

    context "when not anonymous" do
      let(:anonymous) { false }

      it { expect(user.email_or_id).to eq(user.email) }
    end
  end
end
