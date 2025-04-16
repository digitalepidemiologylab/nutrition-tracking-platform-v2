# frozen_string_literal: true

class Home::PaperComponent < ApplicationComponent
  def initialize(journal:, title:, authors:, url:)
    @journal = journal
    @title = title
    @authors = authors
    @url = url
  end
end
