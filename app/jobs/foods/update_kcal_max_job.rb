# frozen_string_literal: true

module Foods
  class UpdateKcalMaxJob < ApplicationJob
    include JobLoggable

    queue_as :default

    def perform
      previously_at = JobLog.where(job_name: self.class.name).order(created_at: :desc).pick(:created_at)
      Foods::UpdateKcalMaxService.new.call(datetime: previously_at)
    end
  end
end
