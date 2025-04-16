# frozen_string_literal: true

module Users
  class BadgeCountService
    def initialize(user:)
      @user = user
    end

    def call
      Annotation.info_asked.joins(:dish).merge(Dish.where(user: @user)).count
    end
  end
end
