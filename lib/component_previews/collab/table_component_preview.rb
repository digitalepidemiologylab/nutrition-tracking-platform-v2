# frozen_string_literal: true

module Collab
  class TableComponentPreview < ViewComponent::Preview
    def default
      render(Collab::TableComponent.new) do |tc|
        3.times do |i|
          tc.with_head_td { "title #{i}" }
        end
        5.times do |i|
          tc.with_row do |r|
            3.times do |j|
              r.with_row_td { "#{i} - #{j}" }
            end
          end
        end
      end
    end

    def with_title
      render(Collab::TableComponent.new) do |tc|
        tc.with_title do |t|
          "Table title"
        end

        3.times do |i|
          tc.with_head_td { "title #{i}" }
        end
        5.times do |i|
          tc.with_row do |r|
            3.times do |j|
              r.with_row_td { "#{i} - #{j}" }
            end
          end
        end
      end
    end

    def with_title_and_button
      render(Collab::TableComponent.new) do |tc|
        tc.with_title do |t|
          t.with_additional_element do
            "<a href='#' class='btn btn-primary'>New</a>"
          end
          "Table title"
        end

        3.times do |i|
          tc.with_head_td { "title #{i}" }
        end
        5.times do |i|
          tc.with_row do |r|
            3.times do |j|
              r.with_row_td { "#{i} - #{j}" }
            end
          end
        end
      end
    end
  end
end
