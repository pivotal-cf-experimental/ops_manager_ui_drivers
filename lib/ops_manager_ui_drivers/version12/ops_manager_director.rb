module OpsManagerUiDrivers
  module Version12
    class OpsManagerDirector
      def initialize(browser:)
        @browser = browser
      end

      def configure(configuration)
        Version12::VcenterCredentials.new(browser: browser, product_id: ops_manager_product_id).configure(configuration['vcenter_credentials'])
        Version12::VsphereConfiguration.new(browser: browser, product_id: ops_manager_product_id).configure(configuration['vsphere_configuration'])
        Version12::NetworkConfiguration.new(browser: browser, product_id: ops_manager_product_id).configure(configuration['network_configuration'])
        Version12::NtpServers.new(browser: browser, product_id: ops_manager_product_id).configure(configuration['ntp_configuration'])
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
