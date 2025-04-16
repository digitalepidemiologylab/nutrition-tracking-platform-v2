# frozen_string_literal: true

RSpec.configure do |config|
  def include_param_description(policy_class, action = nil)
    method_name = action.nil? ? "permitted_includes" : "permitted_includes_for_#{action}"
    permitted_includes = policy_class.new(User.new, nil).public_send(method_name)

    "Included related resources (comma-separated). Nested resources are supported (dot-separated). " \
      "Permitted values: #{permitted_includes.map { |i| "`#{i}`" }.join(", ")}"
  end
end
