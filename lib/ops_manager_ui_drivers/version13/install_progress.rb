module OpsManagerUiDrivers
  module Version13
    class InstallProgress
      def initialize(browser:)
        @browser = browser
      end

      def install_success?
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
          output: browser.find('#install-output .output', visible: false).text(:all),
        }
      end

      private

      def open_install_progress
        browser.visit '/install' unless install_progress_open?
        browser.fail_early('Install probably aborted immediately') unless install_progress_open?
        browser.fail_early('Install failed') if browser.all('#install-failure-modal').any?
      end

      def install_progress_open?
        browser.current_path == '/install'
      end

      private

      attr_reader :browser
    end
  end
end
