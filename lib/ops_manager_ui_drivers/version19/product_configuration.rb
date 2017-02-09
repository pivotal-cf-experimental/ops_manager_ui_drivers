require 'ops_manager_ui_drivers/version18/product_configuration'

module OpsManagerUiDrivers
  module Version19
    class ProductConfiguration < Version18::ProductConfiguration
      def product_form(form_name)
        Version19::ProductForm.new(browser: browser, product_name: product_name, form_name: form_name)
      end

      def product_errands
        Version19::ProductErrands.new(browser: browser, product_name: product_name)
      end
    end
  end
end
