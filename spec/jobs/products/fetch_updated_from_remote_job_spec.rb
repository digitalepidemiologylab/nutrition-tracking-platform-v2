# frozen_string_literal: true

require "rails_helper"

describe(Products::FetchUpdatedFromRemoteJob, :freeze_time) do
  let!(:adapter) { instance_double(Foodrepo::ProductAdapter) }
  let!(:fetch_updated_from_remote_service) { instance_double(Products::FetchUpdatedFromRemoteService) }
  let!(:first_job_log) { create(:job_log, job_name: "Products::FetchUpdatedFromRemoteJob", created_at: first_created_at) }
  let(:first_created_at) { 2.days.ago }
  let!(:second_job_log) { create(:job_log, job_name: "Products::FetchUpdatedFromRemoteJob", created_at: second_created_at) }
  let(:second_created_at) { 1.day.ago }
  let(:job) { described_class.new }

  it_behaves_like "job_loggable"

  describe "#perform" do
    before do
      allow(Products::FetchUpdatedFromRemoteService).to receive(:new).and_return(fetch_updated_from_remote_service)
      allow(fetch_updated_from_remote_service).to receive(:call).and_return(true)
    end

    it do
      job.perform_now
      expect(fetch_updated_from_remote_service).to have_received(:call).with(updated_at: second_created_at).once
    end
  end
end
