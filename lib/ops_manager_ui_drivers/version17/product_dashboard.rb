require 'ops_manager_ui_drivers/version16/product_dashboard'

module OpsManagerUiDrivers
  module Version17
    class ProductDashboard < Version16::ProductDashboard
      def import_installation_file(file_path, decryption_passphrase)
        browser.visit '/import/new'

        browser.fill_in 'import[passphrase]', with: decryption_passphrase
        browser.attach_file 'import[file]', file_path
        browser.click_on 'Import'

        browser.poll_up_to_times(20) { browser.assert_text('Successfully imported installation.') }
      end

      def product_available?(product_name, product_version)
        open_dashboard
        browser.all("li.#{product_name} input#product_version[value='#{product_version}']", {visible: false}).any?
      end

      def delete_unused_products
        open_dashboard
        @browser.find('a#delete_unused_products').trigger('click')
      end

      def deleted_product?(product_name)
        open_dashboard
        browser.first("#show-#{product_name.dasherize}-information-action").present?
      end
    end
  end
end
