module OpsManagerUiDrivers
  module Version17
    class AvailableProducts
      include WaitHelper

      def initialize(browser:)
        @browser = browser
      end

      def add_product_to_install(product_name)
        browser.visit '/'
        poll_up_to_times 3 do
          browser.click_on "add-#{product_name}"
          browser.find("#show-#{product_name.dasherize}-configure-action")
        end
      end

      def product_added?(product_name)
        browser.visit '/'
        browser.all("#show-#{product_name.dasherize}-configure-action").any?
      end

      private

      attr_reader :browser

      def dasherized_product_name(product_name)
        product_name.to_s.gsub(/[_]/, '-')
      end
    end
  end
end
