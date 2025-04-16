# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Segmentation) do
  describe "Associations" do
    let(:segmentation) { build(:segmentation) }

    it do
      expect(segmentation)
        .to belong_to(:annotation).inverse_of(:segmentation)
      expect(segmentation)
        .to belong_to(:dish_image).inverse_of(:segmentations)
      expect(segmentation)
        .to belong_to(:segmentation_client).inverse_of(:segmentations)
    end
  end

  describe "Scopes" do
    describe ".stale_requested", :freeze_time do
      let(:stale_time) { described_class::MAX_STALE_TIME.ago }
      let!(:segmentation_success) { create(:segmentation, :received, started_at: stale_time + 1.second) }
      let!(:segmentation_pending_1) { create(:segmentation, :requested, started_at: stale_time - 1.second) }
      let!(:segmentation_pending_2) { create(:segmentation, :requested, started_at: stale_time) }
      let!(:segmentation_pending_3) { create(:segmentation, :requested, started_at: stale_time + 1.second) }

      it { expect(described_class.stale_requested).to contain_exactly(segmentation_pending_2, segmentation_pending_3) }
    end
  end

  describe "Delegations" do
    let(:segmentation) { build(:segmentation) }

    it { expect(segmentation).to delegate_method(:has_image?).to(:annotation) }
  end

  describe "State Machines" do
    describe "status" do
      describe "state" do
        let(:segmentation) { create(:segmentation) }

        it do
          expect(segmentation).to have_state(:initial, :requested, :received, :processed, :error)
        end
      end

      describe "transitions" do
        describe "#request" do
          let(:segmentation) { create(:segmentation) }

          it do
            expect(segmentation.annotation).to be_initial
            expect(segmentation)
              .to transition_from(:initial).to(:requested).on_event(:request!)
            expect(segmentation.annotation).to be_awaiting_segmentation_service
          end
        end

        describe "#receive" do
          let(:segmentation) { create(:segmentation, :requested) }

          it do
            expect(segmentation)
              .to transition_from(:requested).to(:received).on_event(:receive)
          end
        end

        describe "#process" do
          let(:segmentation) { create(:segmentation, :received) }

          it do
            segmentation.annotation.send_to_segmentation_service!
            expect(segmentation.annotation).to be_awaiting_segmentation_service
            expect(segmentation.response_body).not_to be_nil
            expect(segmentation)
              .to transition_from(:received).to(:processed).on_event(:process!)
            expect(segmentation.response_body).to be_nil
            expect(segmentation.annotation.reload).to be_annotatable
          end
        end

        describe "#fail" do
          let(:segmentation) { create(:segmentation, :received) }

          describe "when error_kind is not set" do
            it do
              expect(segmentation)
                .not_to transition_from(:initial).to(:error).on_event(:fail)
            end

            it do
              expect(segmentation)
                .not_to transition_from(:requested).to(:error).on_event(:fail)
            end

            it do
              expect(segmentation)
                .not_to transition_from(:received).to(:error).on_event(:fail)
            end
          end

          describe "when error_kind is set" do
            before { segmentation.error_kind = "some error" }

            it do
              expect(segmentation.response_body).not_to be_nil
            end

            it do
              expect(segmentation.annotation).to be_initial
              expect(segmentation)
                .to transition_from(:initial).to(:error).on_event(:fail!)
              expect(segmentation.annotation.reload).to be_annotatable
              expect(segmentation.response_body).to be_nil
            end

            it do
              expect(segmentation.annotation).to be_initial
              expect(segmentation)
                .to transition_from(:requested).to(:error).on_event(:fail!)
              expect(segmentation.annotation).to be_annotatable
              expect(segmentation.response_body).to be_nil
            end

            it do
              expect(segmentation.annotation).to be_initial
              expect(segmentation)
                .to transition_from(:received).to(:error).on_event(:fail!)
              expect(segmentation.annotation).to be_annotatable
              expect(segmentation.response_body).to be_nil
            end
          end
        end
      end

      describe "allowed events" do
        let(:segmentation) { build(:segmentation) }

        context "when status is initial" do
          it { expect(segmentation).to allow_event(:request, :fail) }

          it do
            expect(segmentation).not_to allow_event(:receive, :process)
          end
        end

        context "when status is requested" do
          before { segmentation.request }

          it { expect(segmentation).to allow_event(:receive, :fail) }

          it { expect(segmentation).not_to allow_event(:request, :process) }
        end

        context "when status is received" do
          before do
            segmentation.request
            segmentation.receive
          end

          it { expect(segmentation).to allow_event(:process, :fail) }

          it do
            expect(segmentation).not_to allow_event(
              :request, :receive
            )
          end
        end
      end
    end
  end

  describe "Callbacks" do
    describe "after_create_commit" do
      describe "start_segmentation" do
        let(:segmentation) { build(:segmentation) }

        let(:dish) { create(:dish, :with_dish_image) }

        it do
          expect { segmentation.save }.to have_enqueued_job(Segmentations::StartJob)
            .on_queue("default")
            .with(segmentation: segmentation)
            .once
        end
      end
    end
  end
end
