require 'ops_manager_ui_drivers/version14/product_dashboard'

module OpsManagerUiDrivers
  module Version15
    class ProductDashboard < Version14::ProductDashboard
      def import_installation_file(file_path)
        open_dashboard
        browser.click_on 'toggle-installation-dropdown-action'
        browser.click_on 'show-settings'
        browser.click_on 'close-warning'
        browser.expect(browser.page).to_not browser.have_selector('#close-warning', visible: true)
        browser.attach_file 'import[file]', file_path
        browser.click_on 'import-settings'
        browser.poll_up_to_times(20) { browser.assert_text('Successfully imported installation.') }
      end

      def product_on_dashboard?(product_name)
        open_dashboard
        browser.all("a#show-#{product_name}-configure-action").any?
      end

      def product_complete?(product_name)
        open_dashboard
        browser.all("a#show-#{product_name}-configure-action[data-progress='100']").any?
      end

      def most_recent_install_log
        open_dashboard
        if browser.all('#installation-logs li a', visible: false).any?
          base_url = browser.first('#installation-logs li a', visible: false)[:href]
          browser.visit "#{base_url}.text"
          browser.source
        end
      end

      private

      def allow_privilege_verification_errors
        return if @allowed_ignorable_errors.include?(/required datacenter privileges/i)

        @allowed_ignorable_errors << /required datacenter privileges/i
      end
    end
  end
end
