# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Collaborations::DeactivationsController) do
  let!(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:collaboration) { create(:collaboration, :annotator) }

  before { sign_in(collaborator_admin) }

  describe "#create", :freeze_time do
    context "with turbo_stream format" do
      let(:request) { post(collab_collaboration_deactivation_path(collaboration), headers: turbo_stream_headers) }

      context "when successful" do
        it do
          expect { request }
            .to change { collaboration.reload.deactivated_at }.from(nil).to(Time.current)
          expect(response.body).to match("<turbo-stream action=\"replace\"")
          expect(flash[:notice]).to eq("Collaboration has been deactivated")
        end
      end

      context "when failed" do
        before do
          allow_any_instance_of(Collaboration).to receive(:update).with(any_args).and_return(false)
          allow_any_instance_of(Collaboration).to receive(:errors)
            .and_return(ActiveModel::Errors.new(collaboration).tap { |e| e.add(:base, "Failed") })
        end

        it do
          expect { request }.to not_change { collaboration.reload.deactivated? }.from(false)
          expect(response.body).to match("<turbo-stream action=\"replace\"")
          expect(flash[:alert]).to eq("Failed")
        end
      end
    end
  end

  describe "#destroy", :freeze_time do
    context "with turbo_stream format" do
      before { collaboration.deactivate }

      let(:request) { delete(collab_collaboration_deactivation_path(collaboration), headers: turbo_stream_headers) }

      context "when successful" do
        it do
          expect { request }
            .to change { collaboration.reload.deactivated_at }.from(Time.current).to(nil)
          expect(response.body).to match("<turbo-stream action=\"replace\"")
          expect(flash[:notice]).to eq("Collaboration has been reactivated")
        end
      end

      context "when failed" do
        before do
          allow_any_instance_of(Collaboration).to receive(:update).with(any_args).and_return(false)
          allow_any_instance_of(Collaboration).to receive(:errors)
            .and_return(ActiveModel::Errors.new(collaboration).tap { |e| e.add(:base, "Failed") })
        end

        it do
          expect { request }.to not_change { collaboration.reload.deactivated? }.from(true)
          expect(response.body).to match("<turbo-stream action=\"replace\"")
          expect(flash[:alert]).to eq("Failed")
        end
      end
    end
  end
end
