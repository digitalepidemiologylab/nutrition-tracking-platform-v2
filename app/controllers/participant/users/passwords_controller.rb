# frozen_string_literal: true

module Participant
  module Users
    class PasswordsController < Devise::PasswordsController
      include HasLocale

      def update
        self.resource = resource_class.reset_password_by_token(resource_params)
        yield(resource) if block_given?

        if resource.errors.empty?
          resource.update!(tokens: nil)
          resource.unlock_access! if unlockable?(resource)
          set_flash_message!(:notice, :updated_open_app)
          respond_with(resource, location: root_path)
        else
          set_minimum_password_length
          respond_with(resource, status: :unprocessable_entity)
        end
      end
    end
  end
end
