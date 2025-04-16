# frozen_string_literal: true

module Public
  class BaseController < WebController
    include HasAnnotationsRoute

    layout "public"
  end
end
