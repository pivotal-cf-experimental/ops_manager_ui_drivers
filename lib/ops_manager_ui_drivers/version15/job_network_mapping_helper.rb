module OpsManagerUiDrivers
  module Version15
    class JobNetworkMappingHelper
      PRODUCT_NETWORK_FIELD_NAME = 'product_network_assignment'

      def initialize(product_name:, browser:)
        @product_name = product_name
        @browser = browser
      end

      def assign_product_to_network(network)
        open_form
        browser.find_field(PRODUCT_NETWORK_FIELD_NAME).find(:option, text: network).select_option
        save_form
      end

      def product_network
        open_form
        selected_options = browser.find_field(PRODUCT_NETWORK_FIELD_NAME).all('option[selected]')
        raise ArgumentError, "#{PRODUCT_NETWORK_FIELD_NAME} not selected" if selected_options.empty?
        selected_options.first.text
      end

      private

      attr_reader :product_name, :browser

      def open_form
        browser.visit '/'
        browser.click_on "show-#{product_name}-configure-action"
        browser.click_on "show-#{product_name}-network-assignment-action"
      end

      def save_form
        browser.click_on 'Save'

        unless browser.has_css?('.flash-message.success')
          if browser.has_css?('.flash-message.error')
            raise browser.find('.flash-message.error').text
          else
            raise 'unexpected failure'
          end
        end
      end
    end
  end
end
