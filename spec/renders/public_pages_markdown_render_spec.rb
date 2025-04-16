# frozen_string_literal: true

require "rails_helper"

RSpec.describe(PublicPagesMarkdownRender, type: :render) do
  include Capybara::RSpecMatchers

  let(:text) { "A Header" }
  let(:md_render) { described_class.new }

  describe "#header(text, header_level)" do
    context "with level 1" do
      it do
        expect(md_render.header(text, 1)).to eq("A Header")
      end
    end

    context "with level 2" do
      it do
        expect(md_render.header(text, 2))
          .to have_css("h2.text-xl", text: "A Header")
      end
    end

    context "with level 3" do
      it do
        expect(md_render.header(text, 3))
          .to have_css("h3.text-md", text: "A Header")
      end
    end
  end

  describe "#paragraph(text)" do
    it { expect(md_render.paragraph(text)).to have_css("p.mt-4") }
  end

  describe "#list(contents, list_type)" do
    it do
      expect(md_render.list("<li>list item</li>", :type))
        .to have_css("ul.list-disc.pl-8.mt-4", text: "list item")
    end
  end

  describe "#autolink(link, link_type)" do
    let(:url) { "https://myfoodrepo.org" }

    it do
      expect(md_render.autolink(url, :type))
        .to have_css("a.text-brand[href='#{url}']", text: url)
    end
  end
end
