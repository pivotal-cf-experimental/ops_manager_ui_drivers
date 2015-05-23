module OpsManagerUiDrivers
  module Version11
    class AvailableProducts
      def initialize(browser:)
        @browser = browser
      end

      def add_product_to_install(product_name)
        browser.visit '/'
        browser.click_on "add-#{product_name}"
      end

      def product_added?(product_name)
        browser.visit '/'
        browser.all("#show-#{product_name}-configure-action").any?
      end

      private

      attr_reader :browser

    end
  end
end
