# frozen_string_literal: true

class WebController < ApplicationController
  include HasLocale
  include HasHttpAuth

  rescue_from Pagy::OverflowError do |e|
    raise ActiveRecord::RecordNotFound, e.message
  end
end
