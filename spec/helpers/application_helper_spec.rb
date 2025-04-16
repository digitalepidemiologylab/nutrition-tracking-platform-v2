# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ApplicationHelper) do
  describe "#md_to_html" do
    it "transform markdown to html" do
      expect(helper.md_to_html("test **test**")).to eq("<p>test <strong>test</strong></p>\n")
    end
  end
end
