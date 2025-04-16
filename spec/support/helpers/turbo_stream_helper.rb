# frozen_string_literal: true

RSpec.configure do |config|
  def turbo_stream_headers(headers = {})
    accept_headers = headers.fetch(:Accept, "").split(", ")
    accept_headers += %i[turbo_stream html].map { |type| Mime[type].to_s }
    headers.merge(Accept: accept_headers.uniq.compact.join(", "))
  end
end
