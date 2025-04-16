# frozen_string_literal: true

require "rails_helper"

describe Users::UpdateService do
  let(:user) { create(:user, :with_tokens) }
  let(:participation) { create(:participation, user: user) }
  let(:service) { described_class.new(user: user) }

  describe "#call(params)" do
    context "when user anonymous" do
      let(:user) { create(:user, :anonymous) }
      let(:new_password) { "a_new_password" }
      let(:new_email) { "new_email@myfoodrepo.org" }

      context "when successful" do
        let(:params) {
          {
            attributes: {
              email: new_email,
              password: new_password,
              password_confirmation: new_password
            }
          }
        }

        it do
          expect { service.call(params) }
            .to change { user.reload.anonymous }.from(true).to(false)
            .and(change { user.reload.email }.to(new_email))
            .and(change { user.reload.encrypted_password })
        end

        it { expect(service.call(params)).to be_truthy }
      end

      context "when failed" do
        let(:params) {
          {
            attributes: {
              email: new_email,
              password: new_password,
              password_confirmation: "bad_password"
            }
          }
        }

        it do
          expect { service.call(params) }
            .to not_change { user.reload.anonymous }.from(true)
            .and(not_change { user.reload.email })
            .and(not_change { user.reload.encrypted_password })
          expect(service.errors).to contain_exactly("User: password_confirmation doesn't match Password")
        end
      end
    end
  end
end
