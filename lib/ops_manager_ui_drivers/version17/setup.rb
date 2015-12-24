require 'ops_manager_ui_drivers/version16/setup'

module OpsManagerUiDrivers
  module Version17
    class Setup < Version16::Setup
      def setup_and_login(user:, password:)
        browser.visit '/setup'
        browser.fill_in 'setup[admin_user_name]', with: user, wait: 4
        browser.fill_in 'setup[admin_password]', with: password
        browser.fill_in 'setup[admin_password_confirmation]', with: password
        browser.fill_in 'setup[decryption_passphrase]', with: password
        browser.fill_in 'setup[decryption_passphrase_confirmation]', with: password
        browser.check 'setup_eula_accepted'
        browser.click_on 'create-setup-action'

        login(user: user, password: password) unless browser.has_selector?('#main-page-marker', wait: 1)
      end

      def login(user:, password:)
        Timeout.timeout(150) do
          while browser.current_path.include?('ensure_availability')
            sleep 1
          end
        end
        browser.fill_in 'username', with: user, wait: 4
        browser.fill_in 'password', with: password
        browser.click_on 'Sign in'

        unless browser.has_selector?('#main-page-marker', wait: 4)
          fail(RuntimeError, "failed to log in as #{user}/#{password}.")
        end
      end

      def setup_or_login(user:, password:)
        browser.visit '/'

        if browser.current_path == '/setup'
          setup_and_login(user: user, password: password)
        elsif browser.current_path == '/uaa/login'
          login(user: user, password: password)
        end
      end
    end
  end
end
