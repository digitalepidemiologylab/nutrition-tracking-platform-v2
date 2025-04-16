# frozen_string_literal: true

module Collab
  class CommentTemplatesController < BaseController
    before_action :set_comment_template, only: %i[edit update destroy]
    before_action :set_breadcrumbs

    def index
      authorize(CommentTemplate)
      @comment_templates = policy_scope(CommentTemplate)
        .includes(:translations)
        .order(created_at: :asc)
      @pagy, @comment_templates = pagy(@comment_templates)
    end

    def new
      @comment_template = CommentTemplate.new
      authorize(@comment_template)
      @breadcrumbs << {text: t(".title")}
    end

    def edit
      @breadcrumbs << {text: t(".title")}
    end

    def create
      @comment_template = CommentTemplate.new
      @comment_template.assign_attributes(permitted_attributes(@comment_template))
      authorize(@comment_template)

      if @comment_template.save
        redirect_to collab_comment_templates_path, notice: t(".success")
      else
        @breadcrumbs << {text: t("collab.comment_templates.new.title")}
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @comment_template.update(permitted_attributes(@comment_template))
        redirect_to collab_comment_templates_path, notice: t(".success")
      else
        @breadcrumbs << {text: t("collab.comment_templates.edit.title")}
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @comment_template.destroy
        redirect_to collab_comment_templates_path, notice: t(".success"), status: :see_other
      else
        redirect_to collab_comment_templates_path, alert: t(".failure")
      end
    end

    private def set_comment_template
      @comment_template = CommentTemplate.find(params[:id])
      authorize(@comment_template)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.comment_templates"), url: collab_comment_templates_path}]
    end
  end
end
