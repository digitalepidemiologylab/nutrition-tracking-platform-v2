# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  def initialize(flash)
    @flash = flash[:flash]
    @key = @flash.first
    @text = @flash.last
    @negative = @key.to_sym.in?(%i[warning alert danger error])
  end
end
