require 'time'
require 'active_support'
require 'active_support/core_ext'

module OpsManagerUiDrivers
  module WaitHelper
    SLEEP_INTERVAL = 0.5

    EarlyFailException = Class.new(Exception)

    def fail_early(msg)
      fail(EarlyFailException.new(msg))
    end

    def poll_up_to_mins(minutes, sleep_interval = SLEEP_INTERVAL, &blk)
      title = "Polling for #{minutes} mins"

      Logger.debug "--- BEGIN #{title}"
      retry_until(minutes_to_time(minutes), sleep_interval, &blk)
    ensure
      Logger.debug "--- END   #{title}"
    end

    def poll_up_to_times(times, sleep_interval = SLEEP_INTERVAL, &blk)
      title = "Polling for #{times} times"

      Logger.debug "--- BEGIN #{title}"
      retry_times(times, sleep_interval, &blk)
    ensure
      Logger.debug "--- END   #{title}"
    end

    private

    # We're rescuing StandardError because Capybara throws random stuff at us.

    def retry_times(retries, sleep_interval, &blk)
      blk.call
    rescue EarlyFailException
      raise
    rescue RSpec::Expectations::ExpectationNotMetError, StandardError => e
      retries -= 1
      Logger.debug "------- retries_left=#{retries}"
      if retries > 0
        sleep(sleep_interval)
        retry
      else
        Logger.debug "------- propagate error=#{e}"
        raise
      end
    end

    def retry_until(end_time, sleep_interval, &blk)
      blk.call
    rescue EarlyFailException
      raise
    rescue RSpec::Expectations::ExpectationNotMetError, StandardError => e
      seconds_left = (end_time - Time.now).round
      last_logged_at ||= 1.seconds.ago

      if seconds_left % 10 == 0 && (Time.now - last_logged_at).round != 0
        Logger.debug "------- seconds_left=#{seconds_left}"
      end

      if seconds_left > sleep_interval
        sleep(sleep_interval)
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
