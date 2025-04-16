# frozen_string_literal: true

class BaseQuery
  def initialize(initial_scope:, policy: nil)
    @initial_scope = initial_scope
    @policy = policy
  end

  private def includes(scoped, includes)
    return scoped if includes.blank?

    scoped.includes(includes)
  end

  private def order_by_translated_associated_model_attribute(scoped, model:, attribute:, direction:)
    locales = I18n.fallbacks[I18n.locale]
    model_underscored = model.to_s.underscore
    model_table_name = model.to_s.tableize
    model_tranlations_table_name = "#{model_underscored}_translations"
    foreign_key = model.to_s.foreign_key
    scoped_table = scoped.class.to_s.deconstantize.tableize

    # join model
    model_join = <<~SQL.squish
      JOIN #{model_table_name} #{model_underscored}
        ON #{model_underscored}.id = #{scoped_table}.#{foreign_key}
    SQL
    # join model attribute translations
    translations_join = locales.map do |locale|
      <<~SQL.squish
        LEFT JOIN #{model_tranlations_table_name} #{model_underscored}_t_#{locale}
          ON #{model_underscored}_t_#{locale}.#{foreign_key} = #{model_underscored}.id
          AND #{model_underscored}_t_#{locale}.locale = '#{locale}'
      SQL
    end
    join_query = "#{model_join} #{translations_join.join(" ")}"

    order_query = <<~SQL.squish
      UNACCENT(LOWER(COALESCE(
        #{locales.map { |locale| "#{model_underscored}_t_#{locale}.#{attribute}" }.join(", ")},
      ''))) #{direction}
    SQL

    scoped
      .joins(Arel.sql(join_query))
      .order(Arel.sql(ActiveRecord::Base.sanitize_sql_for_order(order_query)))
  end

  class BadFilterParam < StandardError; end
end
