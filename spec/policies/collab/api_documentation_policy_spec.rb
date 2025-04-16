# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::ApiDocumentationPolicy) do
  let(:collaborator) { create(:collaborator) }

  permissions :api_v2?, :collab_api_v1? do
    it { expect(described_class).to permit(collaborator) }
  end
end
