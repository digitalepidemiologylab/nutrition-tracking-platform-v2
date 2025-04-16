# frozen_string_literal: true

module Collab
  class NoteFormsController < BaseController
    before_action :set_note_form

    def show
    end

    def edit
    end

    def update
      if @note_form.save(permitted_attributes(@note_form))
        flash[:notice] = t(".success")
        redirect_to(polymorphic_path([:collab, @notable, :note_forms]))
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private def set_note_form
      @notable = User.find(params[:user_id])
      @note_form = ::NoteForm.new(notable: @notable)
      authorize(@note_form)
    end
  end
end
