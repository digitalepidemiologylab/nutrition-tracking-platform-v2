# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::PushTokenPolicy) do
  let(:user) { build(:user) }
  let(:policy) { described_class }
  let(:user_push_token) { build(:push_token, user: user) }
  let(:push_token) { build(:push_token) }

  permissions :create? do
    it { expect(policy).to permit(user, user_push_token) }
    it { expect(policy).not_to permit(user, push_token) }
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(user, push_token).permitted_attributes)
        .to contain_exactly(attributes: %i[platform token locale])
    end
  end
end
