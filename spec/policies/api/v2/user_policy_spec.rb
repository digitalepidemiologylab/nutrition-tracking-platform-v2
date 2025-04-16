# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::UserPolicy) do
  let(:user) { build(:user) }

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(user, user).permitted_attributes)
        .to contain_exactly(:type, attributes: %i[email password password_confirmation dishes_private])
    end
  end
end
