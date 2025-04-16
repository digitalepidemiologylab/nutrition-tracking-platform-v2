# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ButtonComponent) do
  describe "#render" do
    let(:button) do
      inst = described_class.new(**params)
      render_inline(inst) { "Submit" }
      page
    end

    context "when valid" do
      context "without params" do
        let(:params) { {} }

        it { expect(button).to have_button(class: %w[btn btn-primary], text: "Submit") }
      end

      context "with level :primary" do
        let(:params) { {level: :primary} }

        it { expect(button).to have_button(class: %w[btn btn-primary], text: "Submit") }
      end

      context "with level :secondary" do
        let(:params) { {level: :secondary} }

        it { expect(button).to have_button(class: %w[btn btn-secondary], text: "Submit") }
      end
    end

    context "when invalid" do
      let(:params) { {level: :invalid} }

      it do
        expect { button }
          .to raise_error(ApplicationComponent::InvalidArgumentError, "Level argument must be in primary, secondary")
      end
    end
  end
end
