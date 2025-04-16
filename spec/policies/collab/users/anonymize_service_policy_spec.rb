# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Users::AnonymizeServicePolicy) do
  let(:admin) { create(:collaborator, :admin) }
  let!(:manager) { create(:collaborator) }
  let!(:collaboration) { create(:collaboration, :manager, collaborator: manager) }
  let!(:cohort) { collaboration.cohort }
  let!(:participation) { create(:participation, cohort: cohort) }
  let!(:user) { participation.user }
  let!(:anonymize_service) { Users::AnonymizeService.new(user: user) }

  permissions :update? do
    it do
      expect(described_class).to permit(admin, anonymize_service)
      expect(described_class).not_to permit(manager, anonymize_service)
    end
  end
end
