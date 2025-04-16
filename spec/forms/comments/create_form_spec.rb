# frozen_string_literal: true

require "rails_helper"

describe(Comments::CreateForm) do
  let(:uuid) { Faker::Internet.uuid }
  let(:params) {
    {
      id: uuid,
      silent: silent,
      message: "Hello World"
    }
  }
  let(:form) do
    described_class.new(annotation: annotation, user: user, collaborator: collaborator, view_context: view_context_stub)
  end
  let(:comment) { form.comment }

  before { allow(comment).to receive(:broadcast) }

  describe "#save(params)" do
    let(:annotation) { create(:annotation) }

    context "when associated with user" do
      let(:user) { create(:user) }
      let(:collaborator) { nil }
      let(:silent) { false }

      context "when succesful" do
        it { expect(form.save(params)).to be_truthy }

        it do
          expect { form.save(params) }
            .to change { annotation.comments.count }.by(1)
          expect(comment).to eq(Comment.last)
          expect(comment.id).to eq(uuid)
          expect(comment.user).to eq(user)
          expect(comment.collaborator).to be_nil
          expect(comment.message).to eq("Hello World")
          expect(comment).to have_received(:broadcast).with(view_context: view_context_stub)
        end
      end

      context "when failed" do
        before do
          allow(comment).to receive_messages(invalid?: true, errors: ActiveModel::Errors.new(Comment.new).tap { |e| e.add(:message, "cannot be blank") })
          allow(comment).to receive(:save!)
        end

        it { expect(form.save(params)).to be_falsey }

        it do
          expect { form.save(params) }
            .to not_change { annotation.comments.count }
          expect(form.errors.full_messages).to contain_exactly("Comment: message cannot be blank")
          expect(comment).not_to have_received(:save!)
          expect(comment).not_to have_received(:broadcast).with(view_context: view_context_stub)
        end
      end

      context "when annotation has errors" do
        before do
          allow(annotation).to receive_messages(invalid?: true, errors: ActiveModel::Errors.new(Comment.new).tap { |e| e.add(:base, "is invalid") })
          allow(annotation).to receive(:save!)
        end

        it { expect(form.save(params)).to be_falsey }

        it do
          expect { form.save(params) }
            .to not_change { annotation.comments.count }
          expect(form.errors.full_messages).to contain_exactly("Annotation: is invalid")
        end
      end
    end
  end

  describe "Callbacks" do
    describe "#create_push_notification" do
      let(:collaborator) { nil }
      let(:user) { create(:user) }

      context "when comment.user is different from comment.dish.user" do
        let(:annotation) { create(:annotation, dish: build(:dish)) }

        context "when silent is false" do
          let(:silent) { "0" }

          it do
            expect { form.save(params) }.to have_enqueued_job(Comments::CreatePushNotificationsJob)
              .on_queue("default")
              .with(comment: form.comment)
              .once
          end
        end

        context "when silent is true" do
          let(:silent) { "1" }

          it do
            expect { form.save(params) }.not_to have_enqueued_job(Comments::CreatePushNotificationsJob)
          end
        end
      end

      context "when comment.user is the same as comment.dish.user" do
        let(:annotation) { create(:annotation, dish: build(:dish, user: user)) }

        context "when silent is false" do
          let(:silent) { "0" }

          it do
            expect { form.save(params) }.not_to have_enqueued_job(Comments::CreatePushNotificationsJob)
          end
        end
      end
    end

    describe "#set_annotation_status" do
      context "when silent is false" do
        let(:silent) { "0" }

        context "when posted by user" do
          let(:user) { create(:user) }
          let(:collaborator) { nil }

          context "when annotation may be open" do
            let(:annotation) { create(:annotation, :info_asked) }

            it do
              expect { form.save(params) }
                .to change(annotation, :status).from("info_asked").to("annotatable")
            end
          end

          context "when annotation may not be open" do
            let(:annotation) { create(:annotation, :annotatable) }

            it do
              expect { form.save(params) }
                .not_to change(annotation, :status).from("annotatable")
            end
          end
        end

        context "when posted by collaborator" do
          let(:user) { nil }
          let(:collaborator) { create(:collaborator) }

          context "when annotation may be ask info" do
            let(:annotation) { create(:annotation, :annotatable) }

            it do
              expect { form.save(params) }
                .to change(annotation, :status).from("annotatable").to("info_asked")
            end
          end

          context "when annotation may not be open" do
            let(:annotation) { create(:annotation, :annotated) }

            it do
              expect { form.save(params) }
                .not_to change(annotation, :status).from("annotated")
            end
          end
        end
      end
    end
  end
end
