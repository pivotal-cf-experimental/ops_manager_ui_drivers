module OpsManagerUiDrivers
  module Version12
    class InstallProgress
      def initialize(browser:)
        @browser = browser
      end

      def install_success?
        browser.visit '/install' unless install_progress_open?
        browser.fail_early('Install probably aborted immediately') unless install_progress_open?
        browser.fail_early('Install failed') if browser.all('#install-failure-modal').any?
        browser.all('#install-success-modal').any?
      end

      private

      attr_reader :browser

      def install_progress_open?
        browser.current_path == '/install'
      end
    end
  end
end
