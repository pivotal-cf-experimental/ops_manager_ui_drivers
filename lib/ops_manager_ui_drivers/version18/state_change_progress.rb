require 'ops_manager_ui_drivers/version17/state_change_progress'

module OpsManagerUiDrivers
  module Version18
    class StateChangeProgress < OpsManagerUiDrivers::Version17::StateChangeProgress
      def errand_ran?(errand_name)
        open_install_progress
        !!(/Errand '#{errand_name}' completed successfully \(exit code 0\)/ =~
          browser.find('#install-output .output', visible: false).text(:all))
      end

      def state_change_success?
        load_change_log
        content = browser.find('#change-log > tbody > tr:first-child')
        if content.text.include?('FAILED')
          browser.fail_early('Installation failed!')
        else
          content.text.include?('SUCCEEDED')
        end
      end

      private

      def load_change_log
        browser.visit '/change_log'
        browser.poll_up_to_mins(1) do
          content = browser.find('#change-log > tbody > tr:first-child')
          fail StandardError unless content
          fail StandardError if content.text.include?('Loading')
        end
      end
    end
  end
end
