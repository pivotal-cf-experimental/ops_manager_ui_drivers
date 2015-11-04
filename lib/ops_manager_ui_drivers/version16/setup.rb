require 'ops_manager_ui_drivers/version16/api'

module OpsManagerUiDrivers
  module Version16
    class Setup < Version15::Setup
      def setup_and_login(user:, password:)
        browser.visit '/setup'
        browser.fill_in 'setup[user_name]', with: user, wait: 4
        browser.fill_in 'setup[password]', with: password
        browser.fill_in 'setup[password_confirmation]', with: password
        browser.check 'setup_eula_accepted'
        browser.click_on 'create-setup-action'
        verify_login(user, password)
      end

    end
  end
end
