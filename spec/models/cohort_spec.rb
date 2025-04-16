# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Cohort) do
  describe "Associations" do
    let(:cohort) { build(:cohort) }

    it do
      expect(cohort).to belong_to(:segmentation_client).inverse_of(:cohorts)
      expect(cohort).to have_many(:cohort_food_lists).inverse_of(:cohort).dependent(:restrict_with_error)
      expect(cohort).to have_many(:food_lists).through(:cohort_food_lists)
      expect(cohort).to have_many(:collaborations).inverse_of(:cohort).dependent(:restrict_with_error)
      expect(cohort).to have_many(:participations).inverse_of(:cohort).dependent(:restrict_with_error)
      expect(cohort).to have_many(:users).through(:participations)
      expect(cohort).to have_many(:dishes).through(:users)
    end
  end

  describe "Validations" do
    let(:cohort) { build(:cohort) }

    it { expect(cohort).to be_valid }

    describe "name" do
      it { expect(cohort).to validate_presence_of(:name) }
    end
  end
end
