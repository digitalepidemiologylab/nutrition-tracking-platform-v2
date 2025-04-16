# frozen_string_literal: true

# This is used to refresh PostgreSQL tsvector indices
# No choice than to use SQL for that as this functionality isn't
# natively supported by Rails or the pg_search gem yet.
# Calling this service update all Food, FoodSet or Product.

class RefreshSearchIndicesService
  def initialize(indexable_class:)
    @indexable_class = indexable_class
  end

  def call(ids: nil)
    relation = @indexable_class.unscoped
    relation = relation.where(id: ids) if ids.present?
    query = Arel.sql(sql_query)
    relation.update_all(query)
  end

  def sql_query
    I18n.available_locales.dup.map do |locale|
      sql_locale_query(locale)
    end.join(", ")
  end

  # create the query text for a specific locale
  def sql_locale_query(locale)
    [
      "tsv_document_#{locale} = (TO_TSVECTOR('simple', UNACCENT(COALESCE(",
      I18n.fallbacks[locale].map { |fallback_locale| sql_fallback_locale_query(fallback_locale) }.join(", "),
      ", ''))))"
    ].join
  end

  # create the query text for all fallback locales of a specific locale
  def sql_fallback_locale_query(locale)
    <<-SQL.squish
      NULLIF(
        TRIM(
          (
            SELECT name
            FROM #{@indexable_class.name.underscore}_translations
            WHERE #{@indexable_class.name.underscore}_id = #{@indexable_class.name.tableize}.id
              AND locale = '#{locale}'
            LIMIT 1
          )
        , '')
      , '')
    SQL
  end
end
