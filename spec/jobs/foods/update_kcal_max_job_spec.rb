# frozen_string_literal: true

require "rails_helper"

describe(Foods::UpdateKcalMaxJob, :freeze_time) do
  let!(:update_kcal_max_service) { instance_double(Foods::UpdateKcalMaxService) }
  let(:job) { described_class.new }

  it_behaves_like "job_loggable"

  describe "#perform" do
    before do
      allow(Foods::UpdateKcalMaxService).to receive(:new).and_return(update_kcal_max_service)
      allow(update_kcal_max_service).to receive(:call).and_return(true)
    end

    it do
      job.perform
      expect(update_kcal_max_service).to have_received(:call).with(datetime: nil).once
    end
  end
end
