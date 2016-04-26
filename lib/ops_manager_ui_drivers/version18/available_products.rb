require 'ops_manager_ui_drivers/version17/available_products'

module OpsManagerUiDrivers
  module Version18
    class AvailableProducts < Version17::AvailableProducts
      def add_product_to_install(product_name, product_version=nil)
        browser.visit '/'
        if product_version
          browser.click_on "add-#{product_name}-#{product_version}"
        else
          browser.find(:css, "[id^='add-#{product_name}-']").click
        end
      end
    end
  end
end
