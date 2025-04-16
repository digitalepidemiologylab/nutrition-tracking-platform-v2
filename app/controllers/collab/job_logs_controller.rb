# frozen_string_literal: true

module Collab
  class JobLogsController < BaseController
    before_action :set_breadcrumbs

    def index
      authorize(JobLog)
      @job_logs = policy_scope(JobLog).order(created_at: :desc)
      @pagy, @job_logs = pagy(@job_logs)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.job_logs"), url: collab_job_logs_path}]
    end
  end
end
