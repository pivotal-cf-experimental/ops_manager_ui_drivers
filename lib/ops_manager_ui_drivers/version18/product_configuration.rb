require 'ops_manager_ui_drivers/version17/product_configuration'

module OpsManagerUiDrivers
  module Version18
    class ProductConfiguration < Version17::ProductConfiguration
      def product_form(form_name)
        Version18::ProductForm.new(browser: browser, product_name: product_name, form_name: form_name)
      end

      def product_errands
        Version18::ProductErrands.new(browser: browser, product_name: product_name)
      end
    end
  end
end
