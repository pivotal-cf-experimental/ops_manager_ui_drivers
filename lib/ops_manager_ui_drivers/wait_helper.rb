require 'time'

module OpsManagerUiDrivers
  module WaitHelper
    SLEEP_INTERVAL = 0.5

    EarlyFailException = Class.new(Exception)

    def fail_early(msg)
      fail(EarlyFailException.new(msg))
    end

    def poll_up_to_mins(minutes, &blk)
      title = "Polling for #{minutes} mins"

      Logger.debug "--- BEGIN #{title}"
      retry_until(minutes_to_time(minutes), &blk)
    ensure
      Logger.debug "--- END   #{title}"
    end

    def poll_up_to_times(times, &blk)
      title = "Polling for #{times} times"

      Logger.debug "--- BEGIN #{title}"
      retry_times(times, &blk)
    ensure
      Logger.debug "--- END   #{title}"
    end

    private

    def retry_times(retries, &blk)
      blk.call
    rescue EarlyFailException
      raise
    rescue RSpec::Expectations::ExpectationNotMetError, RuntimeError => e
      retries -= 1
      Logger.debug "------- retries_left=#{retries}"
      if retries > 0
        sleep(SLEEP_INTERVAL)
        retry
      else
        Logger.debug "------- propagate error=#{e}"
        raise
      end
    end

    def retry_until(end_time, &blk)
      blk.call
    rescue EarlyFailException
      raise
    rescue RSpec::Expectations::ExpectationNotMetError, RuntimeError => e
      seconds_left = (end_time - Time.now).round
      Logger.debug "------- seconds_left=#{seconds_left}"
      if seconds_left > SLEEP_INTERVAL
        sleep(SLEEP_INTERVAL)
        retry
      else
        Logger.debug "------- propagate error=#{e}"
        raise
      end
    end

    def minutes_to_time(minutes)
      Time.now + (minutes * 60)
    end
  end
end
