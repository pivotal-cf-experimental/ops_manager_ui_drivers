module OpsManagerUiDrivers
  module Version11
    class NetworkConfiguration
      def initialize(browser:, product_id:)
        @browser = browser
        @product_id = product_id
      end

      def configure(network_configuration)
        open_network_configuration
        configure_network(network_configuration)
      end

      private

      attr_reader :browser, :product_id

      def open_network_configuration
        browser.visit("/components/#{product_id}/forms/network/edit")
      end

      def configure_network(network_configuration)
        browser.fill_in 'network[subnet]', with: network_configuration['subnet']
        browser.fill_in 'network[reserved_ip_ranges]', with: network_configuration['reserved_ip_ranges']
        browser.fill_in 'network[dns]', with: network_configuration['dns']
        browser.fill_in 'network[gateway]', with: network_configuration['gateway']
        browser.click_on 'Save'
      end
    end
  end
end
