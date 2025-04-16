# frozen_string_literal: true

module SearchableByName
  extend ActiveSupport::Concern
  include PgSearch::Model

  included do
    after_commit :refresh_search_indices, on: %i[create update], if: :name_changed?

    scope :search, ->(q) {
      q = q&.strip
      return self if q.blank?

      # Special chars are considered as spaces by tsvector so we need
      # to have a custom logic to search by special chars.
      if /[#$%&+<=>@]/.match?(q)
        filter_by_name_with_special_chars(q)
      else
        query(I18n.locale, q)
      end
    }

    # We use PostgreSQL tsvector ability through the pg_search gem to search Foods and FoodSets.
    # Search indices and search itself are performed with the simple dictionary
    # as Foods and FoodSets names are mostly common words without verbs (a bit like a proper name)
    # so we don't need any matches between variant of words.
    # We search by tsearch (Full text search) but sort result by trigram to return the closest
    # names to search term first (we had to install PostgreSQL pg_tigram extension for that).
    # We also of course ignore accents in both the searchable text and the query
    # terms (we had to install PostgreSQL unaccent extension for that).
    pg_search_scope :query, lambda { |locale, query|
      {
        against: "tsv_document_#{locale}",
        query: query,
        ignoring: :accents,
        ranked_by: ":trigram",
        using: {
          tsearch: {
            dictionary: :simple,
            tsvector_column: "tsv_document_#{locale}",
            prefix: true,
            normalization: 2
          }
        }
      }
    }

    def self.filter_by_name_with_special_chars(q)
      # Find results regardless of word order and diacritics with prefix matches.
      # Tokenize the query with the same logic as tsvector except for the chars we
      # don't care about (first part of regex)
      # and keeps the characters we care about in the query (second part of regex, after the |).
      query = "^"
      q.split(split_regex).uniq.each do |token|
        next if token.length.zero?

        # match beginning of word
        prefix_match = "\\m" if token.length > 1

        # ?= for positive lookahead: Match at any point where a substring matching q begins
        query += "(?=.*#{prefix_match}#{Regexp.quote(token)})"
      end.join

      sql_query = <<-SQL.squish
      UNACCENT(
        COALESCE(
          (
            SELECT name
            FROM #{name.underscore}_translations ms
            WHERE #{name.underscore}_id = #{name.tableize}.id
              AND locale = :locale
            LIMIT 1
          )
        , '')
      ) ~* UNACCENT(:query)
      SQL

      where(sanitize_sql_for_conditions([sql_query, type: name, locale: I18n.locale, query: query]))
    end

    def self.split_regex
      /
        (?:                         # Non-capturing group. Groups multiple tokens together
                                    # without creating a capture group.
          [\s!"()*,:;?\[\\\]^_`{|}] # Match any character in the set.
          +                         # Match 1 or more of the preceding token.
        )
        |                           # Alternation. Acts like a boolean OR. Matches the expression before
                                    # or after the pipe
        (                           #  Capturing group. Groups multiple tokens together and creates a capture group
                                    # for extracting a substring or using a backreference.
          [#$%&+<=>@]               # Match any character in the set.
        )
      /x # x to ignore whitespace
    end

    def refresh_search_indices
      RefreshSearchIndicesService.new(indexable_class: self.class).call(ids: id)
    end

    def name_changed?
      I18n.available_locales.any? { |locale| saved_change_to_attribute?(:"name_#{locale}") }
    end
  end
end
