# frozen_string_literal: true

require "rails_helper"

describe(Collab::JobLogsController) do
  let(:collaborator) { create(:collaborator, :admin) }

  before { sign_in(collaborator) }

  describe "#index" do
    let!(:job_log) { create(:job_log) }

    it do
      get collab_job_logs_path
      expect(response).to have_http_status(:success)
    end
  end
end
