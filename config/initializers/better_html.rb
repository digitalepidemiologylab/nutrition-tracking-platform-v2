# frozen_string_literal: true

if Rails.env.in?(%w[development test])
  BetterHtml.configure do |config|
    config.template_exclusion_filter = proc { |filename|
      !filename.start_with?(Rails.root.to_s) ||
        # Need to exclude lookbook files because they are rendered in our layout
        filename.include?("/lookbook/")
    }
  end
end
