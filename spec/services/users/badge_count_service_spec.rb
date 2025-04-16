# frozen_string_literal: true

require "rails_helper"

describe Users::BadgeCountService do
  let!(:user) { create(:user) }
  let!(:dish) { create(:dish, user: user) }
  let(:service) { described_class.new(user: user) }

  describe "#call" do
    context "when there are no annotations" do
      it do
        expect(service.call).to eq(0)
      end
    end

    context "when there are annotations" do
      before do
        create_list(:annotation, 2, dish: dish)
        create_list(:annotation, 3, :info_asked, dish: dish)
      end

      it do
        expect(service.call).to eq(3)
      end
    end
  end
end
