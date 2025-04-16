# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::MePolicy) do
  let(:user) { build(:user) }

  permissions :show?, :destroy? do
    it { expect(described_class).to permit(user) }
  end
end
