# frozen_string_literal: true

require "rails_helper"

describe(JobLog) do
  describe "Status state machine" do
    let(:job_log) { build(:job_log) }

    describe "state" do
      it do
        expect(job_log).to have_state(:initial, :processing, :failed, :succeeded)
      end
    end

    describe "transitions" do
      it do
        expect(job_log)
          .to transition_from(:initial).to(:processing).on_event(:process)
        expect(job_log)
          .to transition_from(:failed).to(:processing).on_event(:process)
        expect(job_log)
          .to transition_from(:succeeded).to(:processing).on_event(:process)
      end

      it do
        expect(job_log)
          .to transition_from(:processing).to(:failed).on_event(:fail)
      end

      it do
        expect(job_log)
          .to transition_from(:processing).to(:succeeded).on_event(:succeed)
      end
    end

    describe "allowed events" do
      context "when status is initial" do
        it do
          expect(job_log).to allow_event(:process)
          expect(job_log).not_to allow_event(:fail, :succeed)
        end
      end

      context "when status is processing" do
        before do
          job_log.process
        end

        it do
          expect(job_log).to allow_event(:fail, :succeeded)
          expect(job_log).not_to allow_event(:process)
        end
      end

      context "when status is failed" do
        before do
          job_log.process
          job_log.fail
        end

        it do
          expect(job_log).to allow_event(:process)
          expect(job_log).not_to allow_event(:succeed)
        end
      end

      context "when status is succeeded" do
        before do
          job_log.process
          job_log.succeed
        end

        it do
          expect(job_log).to allow_event(:process)
          expect(job_log).not_to allow_event(:fail)
        end
      end
    end
  end

  describe "Validations" do
    describe "job_id and job_name" do
      let(:job_log) { build(:job_log) }

      it do
        expect(job_log).to validate_presence_of(:job_id)
        expect(job_log).to validate_presence_of(:job_name)
      end
    end

    describe "end_at" do
      let(:job_log) { build(:job_log, start_at: start_at, end_at: end_at) }

      context "when start_at is nil" do
        let(:start_at) { nil }
        let(:end_at) { Time.current }

        it do
          expect(job_log).to be_valid
        end
      end

      context "when end_at is nil" do
        let(:start_at) { Time.current }
        let(:end_at) { nil }

        it do
          expect(job_log).to be_valid
        end
      end

      context "when end_at > start_at" do
        let(:end_at) { 1.minute.ago }
        let(:start_at) { 2.minutes.ago }

        it do
          expect(job_log).to be_valid
        end
      end

      context "when end_at < start_at" do
        let(:start_at) { Time.current }
        let(:end_at) { 1.minute.ago }

        it do
          expect(job_log).not_to be_valid
          expect(job_log.errors.full_messages).to include("End at must be greater than Start at")
        end
      end
    end
  end
end
