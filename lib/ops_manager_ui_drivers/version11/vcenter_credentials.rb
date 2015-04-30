module OpsManagerUiDrivers
  module Version11
    class VcenterCredentials

      def initialize(browser:, product_id:)
        @browser = browser
        @product_id = product_id
      end

      def configure(vcenter_credentials_configuration)
        open_vcenter_credentials
        configure_vcenter_credentials(vcenter_credentials_configuration)
      end

      private

      attr_reader :browser, :product_id

      def open_vcenter_credentials
        browser.visit "/components/#{product_id}/forms/vcenter/edit"
      end

      def configure_vcenter_credentials(vcenter_credentials_configuration)
        browser.fill_in 'vcenter[vcenter_ip]', with: vcenter_credentials_configuration['ip_address']
        browser.fill_in 'vcenter[login_credentials][identity]', with: vcenter_credentials_configuration['identity']
        browser.fill_in 'vcenter[login_credentials][password]', with: vcenter_credentials_configuration['password']
        browser.click_on 'Save'
      end
    end
  end
end
