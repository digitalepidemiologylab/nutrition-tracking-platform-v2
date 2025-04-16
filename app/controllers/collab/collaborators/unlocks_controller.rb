# frozen_string_literal: true

module Collab
  module Collaborators
    class UnlocksController < Devise::UnlocksController
      include HasLocale
    end
  end
end
