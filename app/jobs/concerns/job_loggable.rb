# frozen_string_literal: true

module JobLoggable
  extend ActiveSupport::Concern

  included do
    around_perform do |job, block|
      job_log = JobLog.find_or_create_by!(job_id: job_id, job_name: self.class.to_s)
      job_log.process! unless job_log.processing?
      block.call
      job_log.succeed!
    rescue => e
      job_log.fail!(e)
      raise e
    end
  end
end
