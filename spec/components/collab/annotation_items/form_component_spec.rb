# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::AnnotationItems::FormComponent) do
  let!(:cohort) { create(:cohort, :with_food_list) }
  let!(:participation) { create(:participation, cohort: cohort) }
  let!(:food_list) { cohort.food_lists.first }
  let!(:annotation) { create(:annotation, participation: participation) }
  let(:collaborator) { create(:collaborator, :admin) }
  let!(:banana) { create(:food, name_en: "Banana", name_fr: "Banane", food_list: food_list) }

  before { create_base_units }

  describe "#options" do
    let(:food_set_1) { create(:food_set, name: "Food set 1 name") }
    let(:food_set_2) { create(:food_set, name: "Food set 2 name") }
    let!(:food_1) { create(:food, food_sets: [food_set_1], name: "Food 1 name", food_list: food_list) }
    let!(:food_2) { create(:food, food_sets: [food_set_2], name: "Food 2 name", food_list: food_list) }
    let!(:food_3) { create(:food, food_sets: [food_set_1], name: "Food 3 name", food_list: food_list) }
    let(:component) { described_class.new(annotation_item: annotation_item, collaborator: collaborator, units: Unit.all) }

    context "when annotation_item has a food_set_id" do
      context "when food_set_id == food.id" do
        let(:annotation_item) do
          create(
            :annotation_item,
            annotation: annotation,
            food: food_1,
            food_set: food_set_1,
            present_quantity: 10, present_unit: create(:unit, :mass),
            consumed_quantity: 20, consumed_unit: create(:unit, :volume)
          )
        end

        it do
          expect(component.options)
            .to eq("<optgroup label=\"Food Set - `Food set 1 name`\"><option data-unit-id=\"g\" data-portion-quantity=\"10.0\" selected=\"selected\" value=\"#{food_1.id}\">Food 1 name</option>\n<option data-unit-id=\"g\" data-portion-quantity=\"10.0\" value=\"#{food_3.id}\">Food 3 name</option></optgroup>")
        end
      end
    end

    context "when annotation_item has no food_set_id" do
      context "when food_set_id == food.id" do
        let(:annotation_item) do
          create(
            :annotation_item,
            annotation: annotation,
            food: food_1,
            food_set: nil,
            present_quantity: 10, present_unit: create(:unit, :mass),
            consumed_quantity: 20, consumed_unit: create(:unit, :volume)
          )
        end

        it do
          expect(component.options)
            .to eq("<option data-unit-id=\"g\" data-portion-quantity=\"10.0\" selected=\"selected\" value=\"#{food_1.id}\">Food 1 name</option>")
        end
      end
    end
  end

  describe "#displayed_calculated_consumed_info" do
    let(:annotation_item) do
      create(
        :annotation_item,
        annotation: annotation,
        food: banana,
        present_quantity: 10, present_unit: create(:unit, :mass),
        consumed_quantity: 20, consumed_unit: create(:unit, :volume)
      )
    end
    let(:component) { described_class.new(annotation_item: annotation_item, collaborator: collaborator, units: Unit.all) }

    context "when annotation_item has neither consumed_percent nor consumed_quantity" do
      it { expect(component.displayed_calculated_consumed_info).to be_nil }
    end

    context "when annotation_item has consumed_quantity but not consumed_percent" do
      before { allow(annotation_item).to receive(:consumed_kcal).and_return(150) }

      it { expect(component.displayed_calculated_consumed_info).to eq("= 150 kcal") }
    end

    context "when annotation_item has consumed_percent but not consumed_quantity" do
      before { allow(annotation_item).to receive(:consumed_percent).and_return(33) }

      it { expect(component.displayed_calculated_consumed_info).to eq("= 3.3 g") }
    end

    context "when annotation_item has consumed_percent and consumed_quantity" do
      before {
        allow(annotation_item).to receive_messages(consumed_kcal: 150, consumed_percent: 33)
      }

      it { expect(component.displayed_calculated_consumed_info).to eq("= 3.3 g (150 kcal)") }
    end
  end

  describe "#additional_data" do
    let(:annotation_item) do
      create(
        :annotation_item,
        annotation: annotation,
        food: banana,
        polygon_set: polygon_set,
        present_quantity: 10, present_unit: create(:unit, :mass),
        consumed_quantity: 20, consumed_unit: create(:unit, :volume),
        food_set: food_set,
        original_food_set: original_food_set
      )
    end
    let(:polygon_set) { build(:polygon_set, :with_ml_confidence) }
    let(:component) { described_class.new(annotation_item: annotation_item, collaborator: collaborator, units: Unit.all) }

    context "when original_food_set is present and food_set == original_food_set" do
      let(:food_set) { create(:food_set) }
      let(:original_food_set) { food_set }

      it do
        expect(component.additional_data)
          .to eq({food_set_id: food_set.id, ml_confidence: polygon_set.ml_confidence})
      end
    end

    context "when original_food_set is present and food_set != original_food_set" do
      let(:food_set) { create(:food_set) }
      let(:original_food_set) { create(:food_set) }

      it do
        expect(component.additional_data)
          .to eq({food_set_id: food_set.id, original_food_set_id: original_food_set.id, ml_confidence: polygon_set.ml_confidence})
      end
    end
  end

  context "when consumed quantity != present_quantity" do
    let(:annotation_item) do
      create(
        :annotation_item,
        annotation: annotation,
        food: banana,
        present_quantity: 10, present_unit: create(:unit, :mass),
        consumed_quantity: 20, consumed_unit: create(:unit, :volume),
        position: 3
      )
    end

    it do
      render_inline(described_class.new(annotation_item: annotation_item, units: Unit.all, collaborator: collaborator))
      expect(page)
        .to have_field("annotation_item[id]", type: :hidden, with: annotation_item.id, id: "3_annotation_item_id")
      expect(page)
        .to have_select("annotation_item[food_id]", selected: "Banana")
      expect(page)
        .to have_field("annotation_item[present_quantity]", type: :text, with: "10.0")
      expect(page)
        .to have_select("annotation_item[present_unit_id]", selected: "g")
      expect(page)
        .to have_field("annotation_item[consumed_quantity]", type: :text, with: "20.0")
      expect(page)
        .to have_select("annotation_item[consumed_unit_id]", selected: "ml")
    end
  end

  context "when consumed quantity == present_quantity" do
    let(:annotation_item) do
      create(
        :annotation_item,
        annotation: annotation,
        food: banana,
        present_quantity: 10, present_unit: create(:unit, :mass),
        consumed_quantity: 10, consumed_unit: create(:unit, :mass)
      )
    end

    it do
      render_inline(described_class.new(annotation_item: annotation_item, units: Unit.all, collaborator: collaborator))
      expect(page)
        .to have_field("annotation_item[consumed_quantity]", type: :text, with: "100")
      expect(page)
        .to have_select("annotation_item[consumed_unit_id]", selected: nil)
      expect(page)
        .to have_select("annotation_item[consumed_unit_id]", selected: nil)
      expect(page)
        .to have_css("div", text: "= 10.0 g")
    end
  end

  context "when consumed_quantity is nil" do
    let(:annotation_item) do
      create(
        :annotation_item,
        annotation: annotation,
        food: banana,
        present_quantity: 10, present_unit: create(:unit, :mass),
        consumed_quantity: nil, consumed_unit: nil
      )
    end

    it do
      render_inline(described_class.new(annotation_item: annotation_item, units: Unit.all, collaborator: collaborator))
      expect(page)
        .to have_field("annotation_item[consumed_quantity]", type: :text, with: "100")
      expect(page)
        .to have_select("annotation_item[consumed_unit_id]", selected: nil)
      expect(page)
        .to have_css("div", text: "= 10.0 g")
    end
  end

  context "when consumed_percent is present" do
    let(:annotation_item) do
      create(
        :annotation_item,
        annotation: annotation,
        food: banana,
        present_quantity: 10, present_unit: create(:unit, :mass),
        consumed_quantity: 50, consumed_unit_id: "%"
      )
    end

    it do
      render_inline(described_class.new(annotation_item: annotation_item, units: Unit.all, collaborator: collaborator))
      expect(page)
        .to have_field("annotation_item[consumed_quantity]", type: :text, with: "50")
      expect(page)
        .to have_select("annotation_item[consumed_unit_id]", selected: nil)
      expect(page)
        .to have_css("div", text: "= 5.0 g")
    end
  end

  context "when present_quantity is 0 and consumed_quantity is 20" do
    let(:annotation_item) do
      create(
        :annotation_item,
        annotation: annotation,
        food: banana,
        present_quantity: 0, present_unit: create(:unit, :mass),
        consumed_quantity: 20, consumed_unit_id: "%"
      )
    end

    it do
      component = described_class.new(annotation_item: annotation_item, units: Unit.all, collaborator: collaborator)
      render_inline(component)
      expect(page)
        .to have_field("annotation_item[consumed_quantity]", type: :text, with: "20")
      expect(page)
        .to have_select("annotation_item[consumed_unit_id]", selected: nil)
      expect(page)
        .to have_css("div", text: "= 0.0 g")
    end
  end

  context "when annotation is not annotatable" do
    let(:annotation_item) do
      create(
        :annotation_item,
        annotation: annotation,
        food: banana,
        present_quantity: 10, present_unit: create(:unit, :mass),
        consumed_quantity: 20, consumed_unit: create(:unit, :volume)
      )
    end

    before { annotation.confirm! }

    it do
      render_inline(described_class.new(annotation_item: annotation_item, units: Unit.all, collaborator: collaborator))
      expect(page)
        .to have_field("annotation_item[id]", type: :hidden, with: annotation_item.id)
      expect(page)
        .to have_select("annotation_item[food_id]", disabled: true, selected: "Banana")
      expect(page)
        .to have_field("annotation_item[present_quantity]", disabled: true, type: :text, with: "10.0")
      expect(page)
        .to have_select("annotation_item[present_unit_id]", disabled: true, selected: "g")
      expect(page)
        .to have_field("annotation_item[consumed_quantity]", disabled: true, type: :text, with: "20.0")
      expect(page)
        .to have_select("annotation_item[consumed_unit_id]", disabled: true, selected: "ml")
    end
  end
end
