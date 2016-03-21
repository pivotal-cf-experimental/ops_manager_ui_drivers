module OpsManagerUiDrivers
  module Version17
    class UserSettings
      def initialize(browser:)
        @browser = browser
      end

      def switch_to_internal_authentication(user: , password:, decryption_passphrase:)
        browser.visit '/settings/edit'
        browser.fill_in 'change_auth_service[admin_user_name]', with: user
        browser.fill_in 'change_auth_service[admin_password]', with: password
        browser.fill_in 'change_auth_service[admin_password_confirmation]', with: password
        browser.fill_in 'change_auth_service[decryption_passphrase]', with: decryption_passphrase
        browser.click_on 'update-auth-service-action'
        wait_for_availability!
      end

      def switch_to_saml_authentication(idp_metadata:, decryption_passphrase:)
        browser.visit '/settings/edit'
        browser.fill_in 'change_auth_service[saml_idp_metadata]', with: idp_metadata
        browser.fill_in 'change_auth_service[decryption_passphrase]', with: decryption_passphrase
        browser.click_on 'update-auth-service-action'
        wait_for_availability!
      end

      def wait_for_availability!
        Timeout.timeout(150) do
          while browser.current_path.include?('ensure_availability')
            sleep 1
          end
        end
      end

      private

      attr_reader :browser
    end
  end
end



