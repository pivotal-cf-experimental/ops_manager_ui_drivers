require 'ops_manager_ui_drivers/version17/user_settings'

module OpsManagerUiDrivers
  module Version18
    class UserSettings < OpsManagerUiDrivers::Version17::UserSettings
      def delete_whole_installation_on_next_apply_updates
        browser.visit '/advanced_tools'
        browser.click_on 'show-delete-installation-modal-action'
        browser.click_on 'delete-installation-action'
      end

      def delete_installation_available?
        browser.visit '/advanced_tools'
        browser.all('#show-delete-installation-modal-action').any?
      end
    end
  end
end



