# frozen_string_literal: true

require "rails_helper"

shared_examples("job_loggable", :freeze_time) do
  let(:job_id) { Faker::Internet.uuid }
  let(:job) { described_class.new }

  before do
    allow(job).to receive(:job_id).and_return(job_id)
  end

  context "without error" do
    it do
      expect { job.perform_now }.to change(JobLog, :count).by(1)

      job_log = JobLog.last
      expect(job_log).to be_succeeded
      expect(job_log.logs).to be_nil
      expect(job_log.job_name).to eq(job.class.name)
      expect(job_log.job_id).to eq(job_id)
      expect(job_log.start_at).to eq(Time.current)
      expect(job_log.end_at).to eq(Time.current)
    end
  end

  context "when error" do
    before do
      allow_any_instance_of(described_class).to receive(:perform).and_raise(ArgumentError, "Custom error")
    end

    it do
      expect { job.perform_now }.to raise_error(ArgumentError)

      job_log = JobLog.last
      expect(job_log).to be_failed
      expect(job_log.logs).to include("Custom error")
      expect(job_log.start_at).to eq(Time.current)
      expect(job_log.end_at).to eq(Time.current)
    end
  end

  context "when second attempt" do
    let!(:job_log) { create(:job_log, job_id: job_id, job_name: job.class.to_s, logs: "First attempt log", start_at: 5.minutes.ago, end_at: 4.minutes.ago) }

    context "when first attempt failed" do
      before do
        job_log.process!
        job_log.fail!
        job_log.update!(start_at: 5.minutes.ago, end_at: 4.minutes.ago)
      end

      it do
        expect { job.perform_now }
          .to not_change(JobLog, :count)
          .and change { job_log.reload.logs }.to(nil)
          .and change(job_log, :succeeded?).to(true)
          .and change(job_log, :start_at).from(5.minutes.ago).to(Time.current)
          .and change(job_log, :end_at).from(4.minutes.ago).to(Time.current)
      end
    end

    context "when first attempt succeeded" do
      before do
        job_log.process!
        job_log.succeed!
        job_log.update!(logs: "First attempt log", start_at: 5.minutes.ago, end_at: 4.minutes.ago)
      end

      it do
        expect { job.perform_now }
          .to not_change(JobLog, :count)
          .and change { job_log.reload.logs }.to(nil)
          .and not_change(job_log, :succeeded?)
          .and change(job_log, :start_at).from(5.minutes.ago).to(Time.current)
          .and change(job_log, :end_at).from(4.minutes.ago).to(Time.current)
      end
    end
  end
end
