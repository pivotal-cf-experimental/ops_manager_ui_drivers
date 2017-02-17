require 'ops_manager_ui_drivers/version110/product_configuration'

module OpsManagerUiDrivers
  module Version111
    class ProductConfiguration < Version110::ProductConfiguration
      def product_form(form_name)
        Version111::ProductForm.new(browser: browser, product_name: product_name, form_name: form_name)
      end

      def product_errands
        Version111::ProductErrands.new(browser: browser, product_name: product_name)
      end
    end
  end
end
