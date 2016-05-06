require 'ops_manager_ui_drivers/version17/state_change_progress'

module OpsManagerUiDrivers
  module Version18
    class StateChangeProgress < OpsManagerUiDrivers::Version17::StateChangeProgress
      def errand_ran?(errand_name)
        open_install_progress
        !!(/Errand '#{errand_name}' completed successfully \(exit code 0\)/ =~
          browser.find('#install-output .output', visible: false).text(:all))
      end
    end
  end
end
