# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Segmentations::Aicrowd::HandleResponseService, :freeze_time) do
  let!(:segmentation) { create(:segmentation) }
  let(:service) { described_class.new(segmentation: segmentation) }

  describe "#call(response: response)" do
    context "when response is MFR.Job.QUEUED" do
      let(:response) do
        instance_double(HTTParty::Response, body: file_fixture("webmock/aicrowd/task_created.json").read, code: 200)
      end

      it do
        expect { service.call(response: response) }
          .to change(segmentation, :status).from("initial").to("requested")
          .and(change(segmentation, :task_id).from(nil).to("1623395843-1eddf41fea9bdd"))
          .and(change(segmentation, :response_code).from(nil).to(200))
          .and(change(segmentation, :response_body).from(nil))
          .and(change(segmentation, :ai_model).from(nil).to("v1.0"))
          .and(not_change(segmentation, :started_at))
          .and(not_change(segmentation, :error_kind))
          .and(change(segmentation, :response_at).from(nil).to(Time.current))
      end
    end

    context "when response is MFR.Job.SUCCESS" do
      let(:response) do
        instance_double(HTTParty::Response, body: file_fixture("webmock/aicrowd/task_succeeded.json").read, code: 200)
      end

      context "when segmentation is initial" do
        it do
          expect { service.call(response: response) }
            .to raise_error(AASM::InvalidTransition, "Event 'receive' cannot transition from 'initial'.")
        end
      end

      context "when segmentation is requested" do
        before { segmentation.request! }

        it do
          expect { service.call(response: response) }
            .to have_enqueued_job(Segmentations::Aicrowd::ParseJob).with(segmentation: segmentation)
            .and(change(segmentation, :status).from("requested").to("received"))
            .and(change(segmentation, :task_id).from(nil).to("1623395843-1eddf41fea9bdd"))
            .and(change(segmentation, :response_code).from(nil).to(200))
            .and(change(segmentation, :response_body).from(nil))
            .and(change(segmentation, :ai_model).from(nil).to("v1.0 124096"))
            .and(not_change(segmentation, :started_at))
            .and(not_change(segmentation, :error_kind))
            .and(change(segmentation, :response_at).from(nil).to(Time.current))
        end
      end
    end

    context "when response is MFR.Job.ERROR" do
      let(:response) do
        instance_double(HTTParty::Response, body: file_fixture("webmock/aicrowd/task_error.json").read, code: 200)
      end

      it do
        expect { service.call(response: response) }
          .to change(segmentation, :status).from("initial").to("error")
          .and(change(segmentation, :task_id).from(nil).to("1623395843-1eddf41fea9bdd"))
          .and(change(segmentation, :response_code).from(nil).to(200))
          .and(not_change(segmentation, :response_body).from(nil))
          .and(change(segmentation, :ai_model).from(nil).to("v1.0 124096"))
          .and(not_change(segmentation, :started_at))
          .and(change { segmentation.reload.error_kind }.from(nil).to("service_error"))
          .and(change(segmentation, :response_at).from(nil).to(Time.current))
      end
    end

    context "when response is unexpected" do
      let(:response) do
        instance_double(HTTParty::Response, body: file_fixture("webmock/aicrowd/task_unexpected.json").read, code: 200)
      end

      it do
        expect { service.call(response: response) }
          .to change(segmentation, :status).from("initial").to("error")
          .and(change(segmentation, :task_id).from(nil).to("1623395843-1eddf41fea9bdd"))
          .and(change(segmentation, :response_code).from(nil).to(200))
          .and(not_change(segmentation, :response_body).from(nil))
          .and(change(segmentation, :ai_model).from(nil).to("v1.0 124096"))
          .and(not_change(segmentation, :started_at))
          .and(change { segmentation.reload.error_kind }.from(nil).to("service_error"))
          .and(change(segmentation, :response_at).from(nil).to(Time.current))
      end
    end
  end
end
