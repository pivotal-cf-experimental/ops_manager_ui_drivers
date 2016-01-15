module OpsManagerUiDrivers
  module Version15
    class StateChangeProgress
      def initialize(browser:)
        @browser = browser
      end

      def state_change_success?
        open_install_progress
        browser.all('#install-success-modal').any?
      end

      def errand_ran?(errand_name)
        open_install_progress
        browser.find('#install-output .output', visible: false).text(:all).
          include?("Errand `#{errand_name}' completed successfully (exit code 0)")
      end

      def errand_ran_with_text?(errand_name)
        {
          errand_ran: errand_ran?(errand_name),
          output:     browser.find('#install-output .output', {visible: false}).text(:all),
        }
      end

      private

      attr_reader :browser

      def open_install_progress
        browser.visit '/install' unless install_progress_open?
        browser.fail_early('Install probably aborted immediately') unless install_progress_open?
        browser.fail_early('Install failed') if browser.all('#install-failure-modal').any?
      end

      def install_progress_open?
        browser.current_path =~ %r(^/+install)
      end
    end
  end
end
