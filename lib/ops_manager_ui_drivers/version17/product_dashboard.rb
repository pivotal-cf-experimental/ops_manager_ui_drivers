require 'ops_manager_ui_drivers/version16/product_dashboard'

module OpsManagerUiDrivers
  module Version17
    class ProductDashboard < Version16::ProductDashboard
      def import_installation_file(_file_path)
        fail('Importing is no longer supported via the Product Dashboard. See Version17::Setup#import_installation_file')
      end

      def product_available?(product_name, product_version)
        open_dashboard
        browser.all("li.#{product_name} input#product_version[value='#{product_version}']", {visible: false}).any?
      end

      def delete_product(product_name)
        open_dashboard
        browser.click_on "open-delete-#{product_name}-modal"
        wait_for_modal_css_transition_to_complete
        browser.click_on "delete-#{product_name}-action"
      end

      def delete_unused_products
        open_dashboard
        @browser.find('a#delete_unused_products').trigger('click')
      end

      def deleted_product?(product_name)
        open_dashboard
        browser.first("#show-#{product_name}-information-action").present?
      end
    end
  end
end
