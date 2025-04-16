# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::JobLogPolicy) do
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let(:collaborator) { create(:collaborator) }
  let!(:job_log) { create(:job_log) }

  permissions :index? do
    it do
      expect(described_class).to permit(collaborator_admin)
      expect(described_class).not_to permit(collaborator)
      expect(described_class).to permit(collaborator_admin, job_log)
      expect(described_class).not_to permit(collaborator, job_log)
    end
  end

  describe Collab::JobLogPolicy::Scope do
    describe "#resolve" do
      context "when admin" do
        it do
          expect(described_class.new(collaborator_admin, JobLog).resolve)
            .to contain_exactly(job_log)
        end
      end

      context "when not admin" do
        it do
          expect(described_class.new(collaborator, JobLog).resolve)
            .to be_empty
        end
      end
    end
  end
end
