require 'time'
require 'benchmark'

module OpsManagerUiDrivers
  module WaitHelper
    SLEEP_INTERVAL = 1

    EarlyFailException = Class.new(Exception)

    def wait(retries_left=20, interval=0.5, &blk)
      blk.call
    rescue EarlyFailException
      raise
    rescue RSpec::Expectations::ExpectationNotMetError, StandardError
      puts "------- retries_left=#{retries_left}"
      retries_left -= 1
      if retries_left > 0
        sleep(interval)
        retry
      else
        puts "------- propagate error=#{retries_left}"
        raise
      end
    end

    def fail_early(msg)
      fail(EarlyFailException.new(msg))
    end

    def poll_up_to_mins(minutes, &blk)
      wait_debug("Polling for up to #{minutes} mins") do
        wait_until(minutes_to_time(minutes), &blk)
      end
    end

    private

    def wait_debug(title, &blk)
      puts("--- BEGIN #{title} @ #{DateTime.now}")
      Benchmark.bm do |x|
        x.report { blk.call }
      end
    ensure
      puts("--- END   #{title} @ #{DateTime.now}")
    end

    def wait_until(end_time, &blk)
      blk.call
    rescue EarlyFailException
      raise
    rescue RSpec::Expectations::ExpectationNotMetError, StandardError
      seconds_left = (end_time - Time.now).round
      puts "------- time_left=#{seconds_left} sec"
      if seconds_left > SLEEP_INTERVAL
        sleep(SLEEP_INTERVAL)
        retry
      else
        puts "------- propagate error=#{seconds_left}"
        raise
      end
    end

    def minutes_to_time(minutes)
      Time.now + (minutes * 60)
    end
  end
end
