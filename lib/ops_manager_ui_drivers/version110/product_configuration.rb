require 'ops_manager_ui_drivers/version19/product_configuration'

module OpsManagerUiDrivers
  module Version110
    class ProductConfiguration < Version19::ProductConfiguration
      def product_form(form_name)
        Version110::ProductForm.new(browser: browser, product_name: product_name, form_name: form_name)
      end

      def product_errands
        Version110::ProductErrands.new(browser: browser, product_name: product_name)
      end
    end
  end
end
