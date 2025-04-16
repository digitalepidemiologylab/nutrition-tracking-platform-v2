# frozen_string_literal: true

require "rails_helper"

describe(Segmentations::GetStaleRequestedJob) do
  let!(:segmentation) { create(:segmentation, :requested) }
  let(:aicrowd_task_adapter) { instance_double(Aicrowd::TaskAdapter) }
  let(:job) { described_class.new }

  describe "#perform(segmentation:)" do
    before do
      allow(Aicrowd::TaskAdapter).to receive(:new).and_return(aicrowd_task_adapter)
      allow(aicrowd_task_adapter).to receive(:read).with(no_args)
    end

    it do
      job.perform(segmentation: segmentation)
      expect(Aicrowd::TaskAdapter).to have_received(:new).with(segmentation: segmentation).once
      expect(aicrowd_task_adapter)
        .to have_received(:read).with(no_args).once
    end
  end
end
