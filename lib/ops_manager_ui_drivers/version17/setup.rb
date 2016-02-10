require 'ops_manager_ui_drivers/version16/setup'

module OpsManagerUiDrivers
  module Version17
    class Setup < Version16::Setup
      def import_installation_file(file_path, decryption_passphrase)
        browser.visit '/import/new'

        browser.fill_in 'import[passphrase]', with: decryption_passphrase
        browser.attach_file 'import[file]', file_path
        browser.click_on 'Import'

        browser.poll_up_to_mins(3) do
          if browser.current_path == '/import/notes'
            browser.click_on 'Continue'
          end
          fail Capybara::ExpectationNotMet unless browser.current_path == '/uaa/login' || browser.current_path == '/'
        end
      end

      def setup_and_login(user:, password:, decryption_passphrase: password)
        browser.visit '/setup'
        browser.click_on 'Internal Authentication'
        browser.fill_in 'setup[admin_user_name]', with: user, wait: 4
        browser.fill_in 'setup[admin_password]', with: password
        browser.fill_in 'setup[admin_password_confirmation]', with: password
        browser.fill_in 'setup[decryption_passphrase]', with: decryption_passphrase
        browser.fill_in 'setup[decryption_passphrase_confirmation]', with: decryption_passphrase
        browser.check 'setup_eula_accepted'
        browser.click_on 'create-setup-internal-action'

        login(user: user, password: password) unless browser.has_selector?('#main-page-marker', wait: 1)
      end

      def setup_with_saml_provider(decryption_passphrase:, idp_metadata:)
        browser.visit '/setup'
        browser.click_on 'Use an Identity Provider'
        browser.fill_in 'setup[decryption_passphrase]', with: decryption_passphrase
        browser.fill_in 'setup[decryption_passphrase_confirmation]', with: decryption_passphrase
        browser.fill_in 'setup[idp_metadata]', with: idp_metadata
        browser.check 'setup_eula_accepted'
        browser.click_on 'create-setup-saml-action'
      end

      def login_saml(username:, password:)
        Timeout.timeout(150) do
          while browser.current_path.include?('ensure_availability')
            sleep 1
          end
        end

        browser.fill_in 'username', with: username
        browser.fill_in 'password', with: password
        browser.click_on 'Login'

        unless browser.has_selector?('#main-page-marker', wait: 4)
          fail(RuntimeError, "failed to log in as #{username}/#{password}.")
        end
      end

      def login(user:, password:)
        Timeout.timeout(180) do
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

      def setup_or_login(user:, password:, decryption_passphrase: password)
        browser.visit '/'

        if browser.current_path == '/setup'
          setup_and_login(user: user, password: password, decryption_passphrase: decryption_passphrase)
        elsif browser.current_path == '/unlock'
          unlock_and_login(user: user, password: password, decryption_passphrase: decryption_passphrase)
        elsif browser.current_path == '/uaa/login'
          login(user: user, password: password)
        end
      end

      private

      def unlock_and_login(user:, password:, decryption_passphrase: password)
        browser.fill_in 'login[passphrase]', with: decryption_passphrase
        browser.click_on 'Login'
        login(user: user, password: password) unless browser.has_selector?('#main-page-marker', wait: 1)
      end
    end
  end
end
