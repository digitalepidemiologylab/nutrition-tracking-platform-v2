# frozen_string_literal: true

module Seeds
  class UnitsImportService
    UNITS = [
      {id: "μg", base_unit: :mass, factor: 1e-6},
      {id: "mg", base_unit: :mass, factor: 1e-3},
      {id: "g", base_unit: :mass, factor: 1},
      {id: "kg", base_unit: :mass, factor: 1000},
      {id: "oz", base_unit: :mass, factor: 28.3495},
      {id: "lb", base_unit: :mass, factor: 453.592},
      {id: "μg RAE", base_unit: :mass, factor: 1e-06},
      {id: "α-TAE", base_unit: :mass, factor: 0.00067},
      {id: "ml", base_unit: :volume, factor: 1},
      {id: "cl", base_unit: :volume, factor: 10},
      {id: "dl", base_unit: :volume, factor: 100},
      {id: "l", base_unit: :volume, factor: 1000},
      {id: "fl oz", base_unit: :volume, factor: 29.6},
      {id: "gallon", base_unit: :volume, factor: 3785.41},
      {id: "cup", base_unit: :volume, factor: 240},
      {id: "tsp", base_unit: :volume, factor: 4.928922},
      {id: "tbsp", base_unit: :volume, factor: 14.786765},
      {id: "kJ", base_unit: :energy, factor: 0.2390},
      {id: "kcal", base_unit: :energy, factor: 1},
      {id: "bread_unit", base_unit: :mass, factor: 12}
    ]

    def call
      ActiveRecord::Base.transaction do
        UNITS.each { |unit| Unit.create!(unit) unless Unit.exists?(id: unit[:id]) }
      end
    end
  end
end
