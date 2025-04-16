# frozen_string_literal: true

require "rails_helper"

describe AppFormBuilder do
  let(:food) { build(:food) }
  let(:form) { described_class.new(:food, food, helper, {}) }

  describe "input[type='text']" do
    let(:output) { form.input(:name_en) }

    context "without errors" do
      it do
        expect(output).to have_css("label", text: "Name")
        expect(output).to have_field(type: "text")
        expect(output).not_to have_css("p")
      end
    end

    context "with errors" do
      before { food.errors.add(:name_en, "can't be blank") }

      it do
        expect(output).to have_css("label", text: "Name en")
        expect(output).to have_field("Name en", type: "text")
        expect(output).to have_css("p", text: "Name en can't be blank")
      end
    end

    context "when attribute is required" do
      let(:output) { form.input(:name, input_html: {required: true}) }

      it do
        expect(output).to have_css("input[required='required']")
      end
    end
  end

  describe "datetime field" do
    let(:output) { form.input(:created_at) }

    it do
      expect(output).to have_css("label", text: "Created at")
      expect(output).to have_field("Created at", type: "datetime-local", class: "mt-1 block w-full border rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-brand focus:border-brand sm:text-sm border-gray-300")
    end
  end

  describe "select" do
    let(:output) do
      form.input(
        :food_list_id,
        collection: FoodList.all,
        value_method: :id,
        text_method: ->(c) { c.name },
        input_html: {required: true}
      )
    end

    context "without errors" do
      it do
        expect(output).to have_css("label", text: "Food list")
        expect(output).to have_css("select[required='required']")
        expect(output).not_to have_css("p", text: "Food list can't be blank")
      end
    end

    context "with errors" do
      before { food.errors.add(:food_list, "can't be blank") }

      it { expect(output).to have_css("p", text: "Food list can't be blank") }
    end
  end

  describe "input[type='submit']" do
    it do
      output = form.submit_input
      expect(output).to have_css("input[type='submit'][value='Create Food']")
    end
  end

  describe "input[type='checkbox']" do
    it do
      output = form.input(:annotatable, as: :boolean)
      expect(output).to have_field("Annotatable", type: "checkbox")
      expect(output).to have_css("label", text: "Annotatable")
    end
  end
end
