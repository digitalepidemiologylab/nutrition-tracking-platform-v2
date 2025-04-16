# frozen_string_literal: true

module JobLogsHelper
  def job_log_duration(job_log:)
    return unless job_log.start_at && job_log.end_at

    distance_of_time_in_words(job_log.start_at, job_log.end_at)
  end
end
