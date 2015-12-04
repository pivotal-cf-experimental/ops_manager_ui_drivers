module OpsManagerUiDrivers
  module Version15
    class AvailableProducts
      def initialize(browser:)
        @browser = browser
      end

      def add_product_to_install(product_name)
        browser.visit '/'
        browser.click_on "add-#{product_name}"
        browser.find("#show-#{product_name.dasherize}-configure-action", wait: 10)
      end

      def product_added?(product_name)
        browser.visit '/'
        browser.all("#show-#{product_name.dasherize}-configure-action").any?
      end

      private

      attr_reader :browser

    end
  end
end
