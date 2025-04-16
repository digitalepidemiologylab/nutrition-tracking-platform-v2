# frozen_string_literal: true

# based on https://brandnewbox.com/notes/2021/03/form-builders-in-ruby/

class AppFormBuilder < ActionView::Helpers::FormBuilder
  delegate :tag, :safe_join, to: :@template

  def input(method, options = {})
    object_type = object_type_for_method(method)
    options[:input_html] ||= {}
    options[:label] = {} if options[:label].nil?
    if options[:label]
      options[:label][:required] = ActiveModel::Type::Boolean.new.cast(options.dig(:input_html, :required))
    end
    input_type = case object_type
    when :date, :datetime, :integer, :float, :uuid then :string
    else object_type
    end

    override_input_type = if options[:as]
      options[:as]
    elsif options[:collection]
      :select
    end

    send("#{override_input_type || input_type}_input", method, options)
  end

  def submit_input(value = nil, options = {})
    options[:class] ||= "btn btn-primary"
    tag.div(class: "px-4 py-3 bg-gray-50 text-right sm:px-6") do
      submit(value, options)
    end
  end

  def error_text(method)
    return unless has_error?(method)

    error_messages = @object.errors.full_messages_for(method)
    if is_belongs_to_association?(method)
      error_messages += @object.errors.full_messages_for(belongs_to_association_name(method))
    end
    tag.p(
      safe_join(error_messages.uniq, tag.br),
      class: "mt-2 text-sm text-red-600"
    )
  end

  private def form_group(method, options = {}, &block)
    tag.div(class: "col-span-4 sm:col-span-2 #{method}") do
      safe_join([
        yield,
        hint_text(options[:hint]),
        error_text(method)
      ].compact)
    end
  end

  private def hint_text(text)
    return if text.nil?

    tag.p(text, class: "mt-2 text-sm text-gray-500")
  end

  private def object_type_for_method(method)
    result = if @object.respond_to?(:type_for_attribute) && @object.has_attribute?(method)
      @object.type_for_attribute(method.to_s).try(:type)
    elsif @object.respond_to?(:column_for_attribute) && @object.has_attribute?(method)
      @object.column_for_attribute(method).try(:type)
    end

    result || :string
  end

  private def has_error?(method)
    return false unless @object.respond_to?(:errors)

    @object.errors.key?(method) ||
      (is_belongs_to_association?(method) && @object.errors.key?(belongs_to_association_name(method)))
  end

  private def belongs_to_associations
    return [] unless object.class.respond_to?(:reflect_on_all_associations)

    @belongs_to_associations ||= object.class.reflect_on_all_associations.select do |association|
      association.is_a?(ActiveRecord::Reflection::BelongsToReflection)
    end
  end

  private def is_belongs_to_association?(method)
    belongs_to_associations.map(&:foreign_key).include?(method.to_s)
  end

  private def belongs_to_association_name(method)
    belongs_to_associations
      .find { |assoc| assoc.foreign_key == method.to_s }
      &.name
  end

  private def app_label(method, options: {}, label_class: nil)
    options ||= {}
    label_class ||= "block text-sm font-medium text-gray-700 #{label_class}".strip
    label_class += " after:content-['_*'] after:text-red-600" if options[:required]
    label(method, options[:text], class: label_class)
  end

  # Inputs and helpers

  private def string_input(method, options = {})
    classes = %(mt-1 block w-full border rounded-md shadow-sm py-2 px-3
      focus:outline-none focus:ring-brand focus:border-brand sm:text-sm).squish
    classes += if options.dig(:input_html, :disabled)
      " border-gray-200 text-gray-400"
    elsif has_error?(method)
      " border-red-300 text-red-900"
    else
      " border-gray-300"
    end

    form_group(method, options) do
      safe_join([
        (app_label(method, options: options[:label]) unless options[:label] == false),
        string_field(
          method,
          merge_input_options({class: classes}, options[:input_html])
        )
      ])
    end
  end

  private def text_input(method, options = {})
    form_group(method, options) do
      safe_join([
        (app_label(method, options: options[:label]) unless options[:label] == false),
        text_area(
          method,
          merge_input_options(
            {
              class: %(mt-1 block w-full border border-gray-300 rounded-md
              shadow-sm py-2 px-3 focus:outline-none focus:ring-brand
              focus:border-brand sm:text-sm #{"is-invalid" if has_error?(method)}).squish
            },
            options[:input_html]
          )
        )
      ])
    end
  end

  private def boolean_input(method, options = {})
    checkbox = tag.div(class: "flex items-center h-5") do
      check_box(
        method,
        merge_input_options(
          {class: "focus:ring-brand h-4 w-4 text-brand border-gray-300 rounded"},
          options[:input_html]
        )
      )
    end
    label = tag.div(class: "ml-3 text-sm") do
      app_label(method, options: options[:label], label_class: "font-medium text-gray-700")
    end
    form_group(method, options) do
      tag.div(class: "relative flex items-start") do
        safe_join([checkbox, label])
      end
    end
  end

  private def collection_input(method, options, &block)
    form_group(method, options) do
      safe_join([
        (app_label(method, options: options[:label]) unless options[:label] == false),
        yield
      ])
    end
  end

  private def select_input(method, options = {})
    value_method = options[:value_method] || :to_s
    text_method = options[:text_method] || :to_s

    classes = %(mt-1 block w-full pl-3 pr-10 py-2 text-base focus:outline-none focus:ring-brand focus:border-brand
      sm:text-sm rounded-md cursor-pointer).squish
    classes += if has_error?(method)
      " border-red-300 text-red-900"
    else
      " border-gray-300"
    end

    collection_input(method, options) do
      collection_select(
        method,
        options[:collection],
        value_method,
        text_method,
        options,
        merge_input_options({class: classes}, options[:input_html])
      )
    end
  end

  private def grouped_select_input(method, options = {})
    # We probably need to go back later and adjust this for more customization
    collection_input(method, options) do
      grouped_collection_select(
        method, options[:collection], :last, :first, :to_s, :to_s, options,
        merge_input_options(
          {class: "custom-select #{"is-invalid" if has_error?(method)}"},
          options[:input_html]
        )
      )
    end
  end

  private def file_input(method, options = {})
    form_group(method, options) do
      safe_join([
        (app_label(method, options: options[:label]) unless options[:label] == false),
        custom_file_field(method, options)
      ])
    end
  end

  private def collection_of(input_type, method, options = {})
    form_builder_method, custom_class, input_builder_method =
      case input_type
      when :radio_buttons then [:collection_radio_buttons,
        "custom-radio", :radio_button]
      when :check_boxes then [:collection_check_boxes,
        "custom-checkbox", :check_box]
      else
        raise "Invalid input_type for collection_of, valid input_types are \":radio_buttons\", \":check_boxes\""
      end

    form_group(method, options) do
      safe_join([
        app_label(method, options: options[:label]),
        tag.br,
        (send(form_builder_method, method, options[:collection], options[:value_method], options[:text_method]) do |b|
          tag.div(class: "custom-control #{custom_class}") {
            safe_join([
              b.send(input_builder_method, class: "custom-control-input"),
              b.label(class: "custom-control-label")
            ])
          }
        end)
      ])
    end
  end

  private def radio_buttons_input(method, options = {})
    collection_of(:radio_buttons, method, options)
  end

  private def check_boxes_input(method, options = {})
    collection_of(:check_boxes, method, options)
  end

  private def string_field(method, options = {})
    field = case object_type_for_method(method)
    when :date then app_date_field(method, options)
    when :datetime then app_datetime_field(method, options)
    when :integer then number_field(method, options)
    when :float then number_field(method, options.merge(step: :any))
    when :string
      case method.to_s
      when /password/ then password_field(method, options)
      when /email/ then email_field(method, options)
      when /phone/ then telephone_field(method, options)
      when /url/ then url_field(method, options)
      else
        text_field(method, options)
      end
    else
      text_field(method, options)
    end
    return field unless has_error?(method)

    tag.div(class: "mt-1 relative rounded-md shadow-sm") do
      safe_join([
        field,
        tag.div(class: "absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none") do
          tag.i(class: "ph-warning-circle text-red-600")
        end
      ])
    end
  end

  private def app_date_field(method, options = {})
    birthday = method.to_s.include?("birth")
    safe_join([
      date_field(method, merge_input_options(options, {data: {datepicker: true}})),
      tag.div {
        date_select(method, {
          order: [:month, :day, :year],
          start_year: birthday ? 1900 : Time.current.year - 5,
          end_year: birthday ? Time.current.year : Time.current.year + 5
        }, {data: {date_select: true}})
      }
    ])
  end

  private def app_datetime_field(method, options = {})
    safe_join([
      datetime_local_field(method, merge_input_options(options, {data: {datepicker: true}}))
    ])
  end

  private def custom_file_field(method, options = {})
    tag.div(class: "input-group") {
      safe_join([
        tag.div(class: "input-group-prepend") {
          tag.span("Upload", class: "input-group-text")
        },
        tag.div(class: "custom-file") {
          safe_join([
            file_field(method, options.merge(class: "custom-file-input", data: {controller: "file-input"})),
            app_label(method, "Choose file...", label_class: "custom-file-label")
          ])
        }
      ])
    }
  end

  private def merge_input_options(options, user_options)
    return options if user_options.nil?

    options.merge(user_options)
  end
end
