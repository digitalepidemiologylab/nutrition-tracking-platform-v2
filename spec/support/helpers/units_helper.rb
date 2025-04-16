# frozen_string_literal: true

RSpec.configure do |config|
  def create_base_units
    create(:unit, :mass)
    create(:unit, :volume)
    create(:unit, :energy)
  end
end
