# frozen_string_literal: true

module Participations
  class CreateForm
    include ActiveModel::Model

    NUMBER_MIN = 1
    NUMBER_MAX = 20

    attr_accessor :number
    attr_reader :cohort, :participations

    validates :number, numericality: {greater_than_or_equal_to: NUMBER_MIN, less_than_or_equal_to: NUMBER_MAX}
    validate :validate_participations

    def initialize(cohort:)
      @cohort = cohort
      @number = NUMBER_MIN
      @participations = []
    end

    def save(params)
      @number = params.fetch(:number, 0).to_i
      number.times do
        participations << @cohort.participations.new
      end

      return false if invalid?

      ActiveRecord::Base.transaction do
        participations.each(&:save!)
        self.number = NUMBER_MIN
      end
    end

    private def validate_participations
      participations.each do |participation|
        promote_errors(participation) if participation.invalid?
      end
    end

    private def promote_errors(participation)
      participation.errors.each do |error|
        errors.add(
          :base,
          "#{I18n.t("activerecord.models.participation", count: 1)}: #{error.full_message}"
        )
      end
    end
  end
end
