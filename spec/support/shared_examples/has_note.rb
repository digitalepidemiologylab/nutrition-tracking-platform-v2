# frozen_string_literal: true

require "rails_helper"

shared_examples("has_note") do
  let(:notable) { build(described_class.name.underscore) }

  describe "Validations" do
    describe "note" do
      it { expect(notable).to validate_length_of(:note).is_at_most(described_class::MAX_NOTE_LENGTH) }
    end
  end
end
