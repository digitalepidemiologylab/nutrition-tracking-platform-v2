# frozen_string_literal: true

module ApplicationHelper
  def md_to_html(markdown, render: Redcarpet::Render::HTML)
    Redcarpet::Markdown.new(render, autolink: true).render(markdown).html_safe # rubocop:disable Rails/OutputSafety
  end

  def datetime_with_zone(datetime:, timezone:)
    "#{l(datetime.in_time_zone(timezone), format: :long)} (#{timezone})"
  end
end
