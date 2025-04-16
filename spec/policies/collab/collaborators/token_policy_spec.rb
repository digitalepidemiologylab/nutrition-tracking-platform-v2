# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Collaborators::TokenPolicy) do
  let(:admin) { create(:collaborator, :admin) }
  let(:collaborator) { create(:collaborator) }
  let(:another_collaborator) { build(:collaborator) }

  permissions :create?, :destroy? do
    it { expect(described_class).to permit(admin) }
    it { expect(described_class).to permit(collaborator, collaborator) }
    it { expect(described_class).not_to permit(collaborator, another_collaborator) }
  end
end
