# frozen_string_literal: true

module Products
  class FetchUpdatedFromRemoteJob < ApplicationJob
    include JobLoggable

    queue_as :default

    def perform
      # As starting to run the job itself creates a new JobLog, we need to
      # fetch the one created by the previous run of this job (hence calling second
      # and not first below)
      last_job_log = JobLog.where(job_name: "Products::FetchUpdatedFromRemoteJob").order(created_at: :desc).limit(2).second

      updated_at = last_job_log&.created_at
      Products::FetchUpdatedFromRemoteService
        .new(adapter: Foodrepo::ProductAdapter.new)
        .call(updated_at: updated_at)
    end
  end
end
