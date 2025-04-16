# frozen_string_literal: true

class PublicPagesMarkdownRender < Redcarpet::Render::HTML
  include ActionView::Helpers::TagHelper

  def header(text, header_level)
    case header_level
    when 2
      tag.h2(text, class: "text-gray-800 text-xl text-center font-bold sm:text-2xl mt-12 mb-6")
    when 3
      tag.h3(text, class: "text-gray-800 text-md text-center font-bold sm:text-lg mt-12 mb-6")
    else
      text
    end
  end

  def paragraph(text)
    tag.p(text.html_safe, class: "mt-4") # rubocop:disable Rails/OutputSafety
  end

  def list(contents, list_type)
    tag.ul(contents.html_safe, class: "list-disc pl-8 mt-4") # rubocop:disable Rails/OutputSafety
  end

  def autolink(link, link_type)
    tag.a(link, href: link, class: "text-brand hover:underline")
  end
end
