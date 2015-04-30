module OpsManagerUiDrivers
  module Version11
    class OpsManagerDirector
      def initialize(browser:)
        @browser = browser
      end

      def configure(configuration)
        Version11::VcenterCredentials.new(browser: browser, product_id: ops_manager_product_id).configure(configuration['vcenter_credentials'])
        Version11::VsphereConfiguration.new(browser: browser, product_id: ops_manager_product_id).configure(configuration['vsphere_configuration'])
        Version11::NetworkConfiguration.new(browser: browser, product_id: ops_manager_product_id).configure(configuration['network_configuration'])
        Version11::NtpServers.new(browser: browser, product_id: ops_manager_product_id).configure(configuration['ntp_configuration'])
      end

      private

      attr_reader :browser

      def ops_manager_product_id
        @ops_manager_product_id ||= begin
          browser.visit '/'
          browser.find('#show-microbosh-configure-action')['href'].gsub('/components/', '').gsub(%r{/.*}, '')
        end
      end
    end
  end
end
