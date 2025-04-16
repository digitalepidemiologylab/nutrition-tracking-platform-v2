# frozen_string_literal: true

require "rails_helper"

describe(JobLogsHelper) do
  describe "#job_log_duration(job_log:)" do
    let(:job_log) { create(:job_log, start_at: start_at, end_at: end_at) }

    context "when job_log start_at is nil" do
      let(:start_at) { nil }
      let(:end_at) { Time.current }

      it do
        expect(helper.job_log_duration(job_log: job_log)).to be_nil
      end
    end

    context "when job_log end_at is nil" do
      let(:start_at) { Time.current }
      let(:end_at) { nil }

      it do
        expect(helper.job_log_duration(job_log: job_log)).to be_nil
      end
    end

    context "when job_log start_at and end_at are set" do
      let(:start_at) { 4.minutes.ago }
      let(:end_at) { 2.minutes.ago }

      it do
        expect(helper.job_log_duration(job_log: job_log)).to eq("2 minutes")
      end
    end
  end
end
