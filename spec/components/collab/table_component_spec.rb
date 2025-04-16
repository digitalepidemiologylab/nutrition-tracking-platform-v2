# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::TableComponent) do
  it "renders the table" do # rubocop:disable RSpec/ExampleLength
    with_request_url "/fr" do
      render_inline(described_class.new) do |tc|
        tc.with_head_td { "column 1" }
        tc.with_head_td(column: :name, params: {sort: "name", direction: "asc", locale: "fr"}) { "name" }
        tc.with_head_td(column: :title, params: {sort: "name", direction: "asc", locale: "fr"}) { "title" }
        5.times do |i|
          tc.with_row do |r|
            3.times do |j|
              r.with_row_td { "#{i} - #{j}" }
            end
          end
        end
      end

      expect(page).to have_css("thead.bg-gray-50")
      expect(page)
        .to have_css("thead tr th", text: "column 1")
      expect(page)
        .to have_css(
          "thead tr th a.text-brand.whitespace-nowrap[href='/fr?direction=desc&sort=name']",
          text: "name"
        )
      expect(page)
        .to have_css(
          "thead tr th a.whitespace-nowrap[href='/fr?direction=asc&sort=title']",
          text: "title"
        )
    end

    with_request_url "/fr?direction=desc&sort=name" do
      render_inline(described_class.new) do |tc|
        tc.with_head_td(column: :name, params: {sort: "name", locale: "fr"}) { "name" }
        tc.with_row do |r|
          r.with_row_td { "Name" }
        end
      end

      expect(page)
        .to have_css(
          "thead tr th a.text-brand.whitespace-nowrap[href='/fr?direction=asc&sort=name']",
          text: "name"
        )
    end
  end

  it "renders the title" do
    render_inline(described_class.new) do |tc|
      tc.with_title { |t| "Table title" }
    end

    expect(page).to have_css("h3", text: "Table title")
  end

  it "renders the title and additional_element" do
    render_inline(described_class.new) do |tc|
      tc.with_title do |t|
        t.with_additional_element do
          "<a href='#' class='btn btn-primary'>New</a>".html_safe
        end
        "Table title"
      end
    end

    expect(page).to have_css("h3", text: "Table title")
    expect(page).to have_link("New")
  end

  it "renders the form" do
    with_request_url("/fr") do
      render_inline(described_class.new) do |tc|
        tc.with_form(stimulus_controller: "a_controller", turbo_frame: "dishes") do |tcf|
          render(tcf.with_select(attribute: :name, options: [["Name", "name"]], selected: "name"))
        end
      end

      expect(page).to have_css("form[data-controller='a_controller'][data-turbo-frame='dishes']")
      expect(page).to have_select("name", selected: "Name")
    end
  end

  context "with force_show_table" do
    it do
      render_inline(described_class.new(force_show_table: true)) do |tc|
      end

      expect(page).to have_table
    end
  end

  context "with table_id" do
    it do
      render_inline(described_class.new(table_id: "a-table-id")) do |tc|
        tc.with_row do |r|
          r.with_row_td { "Name" }
        end
      end

      expect(page).to have_table("a-table-id")
    end
  end

  context "with tbody_id" do
    it do
      render_inline(described_class.new(tbody_id: "a-tbody-id")) do |tc|
        tc.with_row do |r|
          r.with_row_td { "Name" }
        end
      end

      expect(page).to have_css("tbody#a-tbody-id")
    end
  end
end
