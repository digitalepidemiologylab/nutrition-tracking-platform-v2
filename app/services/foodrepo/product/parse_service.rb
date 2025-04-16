# frozen_string_literal: true

module Foodrepo
  module Product
    class ParseService
      CNAME_MAPPING = {
        "-glucan" => "cellulose",
        "biotin" => "vitamin_h",
        "copper_cu" => "copper",
        "energy" => "energy_kj",
        "energy_calories_kcal" => "energy_kcal",
        "fatty_acids_total_saturated" => "fatty_acids_saturated",
        "fatty_acids_total_trans" => "fatty_acids_polyunsaturated",
        "fiber_insoluble" => "water_insoluble_fibers",
        "fiber_soluble" => "water_soluble_fibers",
        "folate_total" => "folate",
        "iodine" => "iodide",
        "manganese_mn" => "manganese",
        "monounsaturated_fatty_acids" => "fatty_acids_monounsaturated",
        "omega-3_fatty_acids" => "omega_3_fatty_acids",
        "omega-6_fatty_acids" => "omega_6_fatty_acids",
        "polyunsaturated_fatty_acids" => "fatty_acids_polyunsaturated",
        "potassium_k" => "potassium",
        "provitamin_a_-carotene" => "alpha_carotene",
        "saturated_fat" => "fatty_acids_saturated",
        "sugars" => "sugar",
        "vitamin_a" => "vitamin_a_activity",
        "vitamin_a_iu" => "vitamin_a_activity",
        "vitamin_b12_cobalamin" => "vitamin_b12",
        "vitamin_b1_thiamin" => "vitamin_b1",
        "vitamin_b2_riboflavin" => "vitamin_b2",
        "vitamin_b3_niacin" => "niacin",
        "vitamin_b5_panthothenic_acid" => "pantothenic_acid",
        "vitamin_b6_pyridoxin" => "vitamin_b6",
        "vitamin_c_ascorbic_acid" => "vitamin_c",
        "vitamin_d_cholacalciferol" => "vitamin_d",
        "vitamin_d_d2_d3_international_units" => "vitamin_d",
        "vitamin_e_tocopherol" => "vitamin_e",
        "vitamin_k" => "vitamin_k1",
        "zinco" => "zinc"
      }

      UNIT_MAPPING = {
        "µg" => "μg",
        "mg" => "mg",
        "g" => "g",
        "kg" => "kg",
        "oz" => "oz",
        "lb" => "lb",
        "IU" => "μg RAE",
        "ml" => "ml",
        "cl" =>	"cl",
        "dl" =>	"dl",
        "l" => "l",
        "floz" => "fl oz",
        "kJ" => "kJ",
        "kCal" => "kcal"
      }

      def initialize(data:)
        @data = data
      end

      def call
        new_data = {}
        new_data = set_name_translations(new_data)
        new_data = set_image_url(new_data)
        new_data = set_product_nutrients(new_data)
        new_data = set_unit_id(new_data)
        new_data = set_portion_quantity(new_data)
        new_data = set_source(new_data)
        new_data = set_fetched_at(new_data)
        {
          barcode: barcode,
          foodrepo_id: set_foodrepo_id,
          data: new_data,
          status: set_status
        }.deep_symbolize_keys
      end

      private def set_foodrepo_id
        @data.fetch("id", nil)
      end

      private def set_status
        return "complete" if @data["status"] == "complete"

        "incomplete"
      end

      private def barcode
        @barcode ||= @data["barcode"]
      end

      private def set_name_translations(new_data)
        I18n.available_locales.each do |locale|
          new_name = @data.dig("name_translations", locale.to_s)
          new_data["name_#{locale}"] = new_name.presence
        end
        new_data
      end

      private def set_image_url(new_data)
        sorted_images = @data["images"].filter_map do |image_data|
          image_data if image_data["categories"].include?("Front")
        end
        images = sorted_images.presence || @data["images"]
        # Some products have no images (like US products), so we need to check for that
        return new_data if images.blank?

        new_data[:image_url] = images.first["xlarge"]
        new_data
      end

      private def set_product_nutrients(new_data)
        new_data[:product_nutrients_attributes] = []
        @data["nutrients"].each do |k, v|
          nutrient_id = CNAME_MAPPING[k.to_s].presence || k
          # Sometimes, a product has twice the same nutrient, like `sugars` and `sugars added`,
          # so we need to prevent this from happening as it would create a validation error
          next if new_data[:product_nutrients_attributes].pluck(:nutrient_id).include?(nutrient_id) ||
            v["per_hundred"].blank?

          new_data[:product_nutrients_attributes] << {
            nutrient_id: nutrient_id,
            per_hundred: v["per_hundred"]
          }
        end
        new_data
      end

      private def set_unit_id(new_data)
        portion_unit = @data["portion_unit"].to_s
        new_data[:unit_id] = UNIT_MAPPING[portion_unit].presence || portion_unit
        new_data
      end

      private def set_portion_quantity(new_data)
        new_data[:portion_quantity] = @data["portion_quantity"]
        new_data
      end

      private def set_source(new_data)
        return new_data if new_data.blank?

        new_data[:source] = ["FoodRepo", Foodrepo::ProductAdapter::BASE_URI, barcode].join("\n")
        new_data
      end

      private def set_fetched_at(new_data)
        return new_data if new_data.blank?

        new_data[:fetched_at] = Time.current
        new_data
      end
    end
  end
end
