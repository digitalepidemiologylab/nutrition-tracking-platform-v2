# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::AnnotationPolicy) do
  let!(:admin) { create(:collaborator, :admin) }

  describe "permissions" do
    let(:api_scope) { described_class.new(admin, Annotation) }
    let(:main_scope) { instance_double(Collab::AnnotationPolicy) }

    before { allow(Collab::AnnotationPolicy).to receive(:new).and_return(main_scope) }

    describe "#index?" do
      before { allow(main_scope).to receive(:index?) }

      it do
        api_scope.index?
        expect(Collab::AnnotationPolicy).to have_received(:new).with(admin, Annotation)
        expect(main_scope).to have_received(:index?)
      end
    end
  end

  describe "#permitted_includes" do
    let(:annotation) { create(:annotation) }

    it do
      expect(described_class.new(admin, annotation).permitted_includes).to contain_exactly(
        "dish",
        "dish.dish_image",
        "intakes",
        "comments",
        "annotation_items",
        "annotation_items.food",
        "annotation_items.food.food_nutrients",
        "annotation_items.product",
        "annotation_items.product.product_nutrients",
        "annotation_items.product.product_images"
      )
    end
  end

  describe Collab::Api::V1::AnnotationPolicy::Scope do
    describe "#resolve" do
      let(:api_scope) { described_class.new(admin, Annotation) }
      let(:main_scope) { instance_double(Collab::AnnotationPolicy::Scope) }

      before do
        allow(Collab::AnnotationPolicy::Scope).to receive(:new).and_return(main_scope)
        allow(main_scope).to receive(:resolve)
      end

      it do
        api_scope.resolve
        expect(Collab::AnnotationPolicy::Scope).to have_received(:new).with(admin, Annotation)
        expect(main_scope).to have_received(:resolve)
      end
    end
  end
end
