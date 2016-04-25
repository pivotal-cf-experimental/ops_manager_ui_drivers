require 'ops_manager_ui_drivers/version17/available_products'

module OpsManagerUiDrivers
  module Version18
    class AvailableProducts < Version17::AvailableProducts
      def add_product_to_install(product_name, product_version)
        browser.visit '/'
        browser.click_on "add-#{product_name}-#{product_version}"
      end
    end
  end
end
