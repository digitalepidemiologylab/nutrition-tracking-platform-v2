# frozen_string_literal: true

require "rails_helper"

describe "foods", :freeze_time do # rubocop:disable RSpec/DescribeClass
  describe "update_kcal_max" do
    let(:service) { instance_double(Foods::UpdateKcalMaxService) }

    before do
      allow(service).to receive(:call)
      allow(Foods::UpdateKcalMaxService).to receive(:new).and_return(service)
    end

    describe ":all" do
      it do
        Rake::Task["foods:update_kcal_max:all"].invoke
        expect(service).to have_received(:call).once.with(no_args)
      end
    end

    describe ":last_2_days" do
      it do
        Rake::Task["foods:update_kcal_max:last_2_days"].invoke
        expect(service).to have_received(:call).once.with(datetime: 2.days.ago)
      end
    end
  end
end
