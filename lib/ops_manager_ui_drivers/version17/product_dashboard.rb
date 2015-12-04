require 'ops_manager_ui_drivers/version16/product_dashboard'

module OpsManagerUiDrivers
  module Version17
    class ProductDashboard < Version16::ProductDashboard
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
