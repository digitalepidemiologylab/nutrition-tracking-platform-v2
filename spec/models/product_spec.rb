# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Product) do
  it_behaves_like "searchable_by_name"

  describe "Association" do
    let(:product) { build(:product) }

    it do
      expect(product).to belong_to(:unit).inverse_of(:products)
      expect(product).to have_many(:annotation_items).inverse_of(:product).dependent(:restrict_with_error)
      expect(product).to have_many(:product_images).inverse_of(:product).dependent(:destroy)
      expect(product).to have_many(:product_nutrients).inverse_of(:product).dependent(:destroy)
    end

    it do
      expect(product).to accept_nested_attributes_for(:product_nutrients)
      expect(product).to accept_nested_attributes_for(:product_images)
    end
  end

  describe "Translation" do
    let(:product) { build(:product, :with_name) }

    it { expect(product).to translate(:name) }
  end

  describe "Validations" do
    let(:product) { build(:product) }

    it { expect(product).to be_valid }

    describe "barcode" do
      it { expect(product).to validate_presence_of(:barcode) }
    end
  end

  describe "Status state machine" do
    let(:product) { build(:product) }

    describe "state" do
      it do
        expect(product).to have_state(:initial, :incomplete, :complete)
      end
    end

    describe "transitions" do
      it do
        expect(product)
          .to transition_from(:initial, :incomplete).to(:complete).on_event(:mark_complete)
      end

      it do
        expect(product)
          .to transition_from(:initial).to(:incomplete).on_event(:mark_incomplete)
      end
    end

    describe "allowed events" do
      context "when status is initial" do
        it do
          expect(product).to allow_event(:mark_complete)
          expect(product).to allow_event(:mark_incomplete)
        end
      end

      context "when status is incomplete" do
        before { product.mark_incomplete }

        it do
          expect(product).to allow_event(:mark_complete)
          expect(product).not_to allow_event(:mark_incomplete)
        end
      end

      context "when status is complete" do
        before do
          product.mark_complete
        end

        it do
          expect(product).to allow_event(:mark_incomplete)
          expect(product).not_to allow_event(:mark_complete)
        end
      end
    end
  end

  describe "Callbacks" do
    describe "before_validation" do
      before { product.validate }

      describe "#normalize_barcode", :en do
        context "when barcode is set and nomalized" do
          let(:barcode) { build(:barcode) }
          let(:product) { build(:product, barcode: barcode.code) }

          it { expect(product.barcode).to eq(barcode.code) }
        end

        context "when barcode is set but not normalized" do
          let(:product) { build(:product, barcode: "  761-165-466-687-5.") }

          it { expect(product.barcode).to eq("7611654666875") }
        end

        context "when barcode is blank" do
          let(:product) { build(:product, barcode: nil) }

          it { expect(product.barcode).to be_nil }
        end
      end
    end

    describe "after_create_commit" do
      describe "#fetch_data" do
        let(:product) { build(:product) }

        it do
          expect { product.save }.to have_enqueued_job(Products::FetchDataJob)
        end
      end
    end
  end
end
