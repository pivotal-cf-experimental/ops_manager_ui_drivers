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

      def delete_unused_product(product_name, product_version=nil)
        browser.visit '/'
        disable_css_transitions!
        if product_version
          browser.click_on "delete-#{product_name}-#{product_version}"
        else
          browser.find(:css, "[id^='delete-#{product_name}-']").click
        end
        browser.find('#delete_unused_products').trigger('click')
      end

      def delete_unused_products
        browser.visit '/'
        disable_css_transitions!
        browser.find('#delete_unused_products_modal').trigger('click')
        browser.find('#delete_unused_products').trigger('click')
      end

      def product_available?(product_name, product_version)
        browser.visit '/'
        browser.all("li.#{product_name} input#product_version[value='#{product_version}']", {visible: false}).any?
      end
    end
  end
end
