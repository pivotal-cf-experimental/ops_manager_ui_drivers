module OpsManagerUiDrivers
  module Version12
    class NtpServers
      def initialize(browser:, product_id:)
        @browser = browser
        @product_id = product_id
      end

      def configure(ntp_configuration)
        open_ntp_configuration
        configure_ntp(ntp_configuration)
      end

      private

      attr_reader :browser, :product_id

      def open_ntp_configuration
        browser.visit("/components/#{product_id}/forms/ntp/edit")
      end

      def configure_ntp(ntp_configuration)
        browser.fill_in 'ntp[ntp_servers]', with: ntp_configuration['ntp']
        browser.click_on 'Save'
      end
    end
  end
end
