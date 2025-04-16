# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples("base_image") do
  let(:base_image_factory) { described_class.name.underscore }

  describe "Validations" do
    describe "#data_is_image" do
      let(:base_image) { create(base_image_factory) }

      context "with a valid file type" do
        before do
          base_image.data.attach(
            io: Rails.root.join("spec/fixtures/images/dishes/burger.jpg").open,
            filename: "burger.jpg",
            content_type: "image/jpeg"
          )
        end

        it do
          expect(base_image).to be_valid
          expect(base_image.data).to be_attached
        end
      end

      context "with an invalid file type" do
        before do
          base_image.data.purge
          base_image.data.attach(
            io: Rails.root.join("spec/fixtures/files/a_csv.csv").open,
            filename: "a_csv.csv",
            content_type: "application/csv"
          )
        end

        it do
          expect(base_image).not_to be_valid
          expect(base_image.data).not_to be_attached
          expect(base_image.errors[:data]).to contain_exactly("is not an image")
        end
      end
    end

    describe "#attachement_is_unique" do
      let(:base_image_1) { create(base_image_factory, :image_1) }
      let(:blob) { base_image_1.data.blob }
      let(:base_image_2) { create(base_image_factory, :image_2) }

      it do
        expect(base_image_2.errors.full_messages).to be_empty
        base_image_2.data.attach(blob)
        expect(base_image_2.errors.full_messages).to contain_exactly("Data has already been taken")
      end
    end
  end
end
