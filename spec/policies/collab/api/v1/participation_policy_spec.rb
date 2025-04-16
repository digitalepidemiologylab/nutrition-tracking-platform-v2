# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::ParticipationPolicy) do
  let!(:cohort) { create(:cohort) }
  let(:admin) { create(:collaborator, :admin) }
  let!(:collaboration_manager) { create(:collaboration, :manager, cohort: cohort) }
  let(:manager) { collaboration_manager.collaborator }
  let!(:collaboration_annotator) { create(:collaboration, :annotator, cohort: cohort) }
  let(:annotator) { collaboration_annotator.collaborator }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager)
      expect(described_class).not_to permit(annotator)
    end
  end

  permissions :create?, :update? do
    let!(:participation) { build(:participation, cohort: cohort) }

    it do
      expect(described_class).to permit(admin, participation)
      expect(described_class).to permit(manager, participation)
      expect(described_class).not_to permit(annotator, participation)
    end
  end

  describe "#permitted_attributes" do
    let!(:participation) { build(:participation, cohort: cohort) }

    it do
      expect(described_class.new(manager, participation).permitted_attributes)
        .to contain_exactly(:type, attributes: %i[ended_at])
    end
  end

  describe "#permitted_includes" do
    let!(:participation) { build(:participation, cohort: cohort) }

    it do
      expect(described_class.new(manager, participation).permitted_includes).to contain_exactly("cohort")
    end
  end

  describe Collab::Api::V1::ParticipationPolicy::Scope do
    describe "#resolve" do
      let(:api_scope) { described_class.new(admin, Participation) }
      let(:main_scope) { instance_double(Collab::ParticipationPolicy::Scope) }

      before do
        allow(Collab::ParticipationPolicy::Scope).to receive(:new).and_return(main_scope)
        allow(main_scope).to receive(:resolve)
      end

      it do
        api_scope.resolve
        expect(Collab::ParticipationPolicy::Scope).to have_received(:new).with(admin, Participation)
        expect(main_scope).to have_received(:resolve)
      end
    end
  end
end
