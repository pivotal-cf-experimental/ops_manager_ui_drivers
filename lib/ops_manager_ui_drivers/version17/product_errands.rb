module OpsManagerUiDrivers
  module Version17
    class ProductErrands
      def initialize(browser:, product_name:)
        @browser = browser
        @product_name = product_name
      end

      def enable_errand(errand_name)
        open_form
        browser.find_field("errands_collection_enabled_names_#{errand_name}").set(true)
        save_form
      end

      def disable_errand(errand_name)
        open_form
        browser.find_field("errands_collection_enabled_names_#{errand_name}").set(false)
        save_form
      end

      def save_form(validate: true)
        browser.click_on 'Save'

        fail('unexpected failure') unless browser.has_css?('.flash-message')

        if validate
          fail(browser.find('.flash-message.error').text) unless browser.has_css?('.flash-message.success')
        end
      end

      def open_form
        browser.visit '/'
        browser.click_on "show-#{product_name}-configure-action"
        browser.click_on "show-product-errands-action"
      end

      private

      attr_reader :browser, :product_name
    end
  end
end
