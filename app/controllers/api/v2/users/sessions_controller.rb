# frozen_string_literal: true

module Api
  module V2
    module Users
      class SessionsController < DeviseTokenAuth::SessionsController
        include HasLocale
        include DeviseSessionMethods
      end
    end
  end
end
