# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::PolygonSetsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let!(:dish) { create(:dish, :with_dish_image) }
  let!(:annotation) { create(:annotation, :annotatable, :with_annotation_item, dish: dish) }
  let!(:annotation_item) { create(:annotation_item, annotation: annotation, polygon_set: polygon_set) }
  let!(:food_1) { create(:food) }

  before do
    sign_in(collaborator)
  end

  describe "#update" do
    context "with turbo_stream format" do
      let(:request) {
        put collab_annotation_item_polygon_set_path(annotation_item), params: {polygon_set: params},
          headers: turbo_stream_headers
      }

      context "with valid params" do
        let(:params) do
          {
            polygons: [
              [
                [0.474453, 0.27633],
                [0.41293, 0.279458],
                [0.622523, 0.497393],
                [0.653806, 0.450469],
                [0.672576, 0.388947],
                [0.676747, 0.347237],
                [0.657977, 0.300313],
                [0.631908, 0.277372]
              ]
            ].to_json
          }
        end

        context "when no previous polygon_set exists" do
          let(:polygon_set) { nil }

          it do
            expect { request }
              .to change(PolygonSet, :count).by(1)
            expect(response.body).to match("<turbo-stream action=\"update\" target=\"flash_messages\"><template>")
          end
        end

        context "when previous polygon_set exists" do
          let!(:polygon_set) { build(:polygon_set) }

          it do
            expect { request }
              .to not_change(PolygonSet, :count)
              .and(change { polygon_set.reload.polygons })
            expect(response.body).to match("<turbo-stream action=\"update\" target=\"flash_messages\"><template>")
          end
        end
      end

      context "with invalid params" do
        let(:polygon_set) { nil }
        let(:params) do
          {
            polygons: [
              [
                [0.474453, 0.27633],
                [0.41293, 0.279458],
                [0.622523, 0.497393],
                [0.653806, 0.450469],
                [0.672576, 0.388947],
                [0.676747, 0.347237],
                [0.657977, 0.300313],
                [0.631908, 0.277372]
              ]
            ]
          }
        end

        it do
          expect { request }
            .not_to change(PolygonSet, :count)
          expect(flash[:alert]).to eq("Unable to update polygons")
          expect(response.body).to match("<turbo-stream action=\"update\" target=\"flash_messages\"><template>")
        end
      end
    end
  end

  describe "#destroy" do
    context "with turbo_stream format" do
      let!(:polygon_set) { build(:polygon_set) }
      let(:request) {
        delete collab_annotation_item_polygon_set_path(annotation_item), headers: turbo_stream_headers
      }

      context "when successful" do
        it do
          expect { request }
            .to change(PolygonSet, :count).by(-1)
          expect(response.body).to match("<turbo-stream action=\"update\" target=\"flash_messages\"><template>")
        end
      end

      context "when failed" do
        before { allow_any_instance_of(PolygonSet).to receive(:destroy).and_return(false) }

        it do
          expect { request }
            .not_to change(PolygonSet, :count)
          expect(flash[:alert]).to eq("Unable to destroy polygons")
          expect(response.body).to match("<turbo-stream action=\"update\" target=\"flash_messages\"><template>")
        end
      end
    end
  end
end
