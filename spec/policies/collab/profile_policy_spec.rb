# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::ProfilePolicy) do
  let(:collaborator) { create(:collaborator) }
  let(:another_collaborator) { build(:collaborator) }

  permissions :show?, :edit?, :update? do
    context "when own profile" do
      it { expect(described_class).to permit(collaborator, collaborator) }
    end

    context "when someone else profile" do
      it { expect(described_class).not_to permit(collaborator, another_collaborator) }
    end
  end
end
