# frozen_string_literal: true

require "rails_helper"

describe Users::AnonymizeService do
  let(:participation) { create(:participation, user: user) }
  let(:service) { described_class.new(user: user) }

  describe "#call" do
    context "when user anonymous" do
      let!(:user) { create(:user, :anonymous, :with_tokens, password: "MyFoodRepoPassword") }

      context "when successful" do
        it do
          expect { service.call }
            .to change { user.reload.encrypted_password }
            .and(change(user, :tokens).to({}))
            .and(not_change { user.anonymous }.from(true))
            .and(not_change { user.email })
        end
      end

      context "when unsuccessful" do
        before do
          allow_any_instance_of(User).to receive(:save!).and_raise(StandardError, "Error message")
        end

        context "when raise_exception is false" do
          it do
            expect { service.call }
              .to not_change { user.reload.encrypted_password }
              .and(not_change(user, :tokens))
              .and(not_change { user.anonymous }.from(true))
              .and(not_change { user.email })
            expect(service.errors.full_messages).to eq(["Error message"])
          end
        end

        context "when raise_exception is true" do
          it do
            expect { service.call(raise_exception: true) }
              .to raise_error(StandardError, "Error message")
          end
        end
      end
    end

    context "when user is not anonymous" do
      let(:user) { create(:user, :with_tokens) }

      context "when successful" do
        it do
          expect { service.call }
            .to change { user.reload.encrypted_password }
            .and(change(user, :tokens).to({}))
            .and(change(user, :anonymous).from(false))
            .and(change(user, :email).to("#{user.id}@#{User::ANONYMOUS_DOMAIN}"))
        end
      end
    end
  end
end
