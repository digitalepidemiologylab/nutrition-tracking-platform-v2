# frozen_string_literal: true

class DeviseCustomController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[locale])
    devise_parameter_sanitizer.permit(:invite, keys: [collaborations_attributes: [:cohort_id, :role]])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name])
  end
end
