# frozen_string_literal: true

require "rails_helper"

describe(Users::DestroyService) do
  let!(:user) { create(:user) }
  let!(:dish) { create(:dish, :with_dish_image, user: user) }
  let!(:participation) { create(:participation, user: user) }
  let!(:comment) { create(:comment, user: user) }
  let!(:push_token) { create(:push_token, user: user) }

  let(:service) { described_class.new(user: user) }

  describe "#call" do
    context "when user has only one participation" do
      it do
        expect(service).to be_valid
        expect(service.call).to be_truthy
        expect(service.errors).to be_empty
      end

      it do
        with_versioning do
          PaperTrail.request(whodunnit: "John Doe") do
            expect { service.call }
              .to change(User, :count).by(-1)
              .and change(Dish, :count).by(-1)
              .and change(Intake, :count).by(-1)
              .and change(DishImage, :count).by(-1)
              .and change(Participation, :count).by(-1)
              .and change(Comment, :count).by(-1)
              .and change(PushToken, :count).by(-1)
              .and change(ActiveStorage::Attachment, :count).by(-1)
              .and change(PaperTrail::Version, :count).by(6)
          end
        end
      end
    end

    context "when user has more than one participation" do
      before { create(:participation, user: user) }

      it do
        expect(service).not_to be_valid
        expect(service.call).to be_falsey
        expect(service.errors.full_messages).to contain_exactly("User can not be deleted as it has more than one participation")
      end

      it do
        with_versioning do
          PaperTrail.request(whodunnit: "John Doe") do
            expect { service.call }
              .to not_change(User, :count)
              .and not_change(Dish, :count)
              .and not_change(Intake, :count)
              .and not_change(DishImage, :count)
              .and not_change(Participation, :count)
              .and not_change(Comment, :count)
              .and not_change(PushToken, :count)
              .and not_change(ActiveStorage::Attachment, :count)
              .and not_change(PaperTrail::Version, :count)
          end
        end
      end
    end
  end
end
