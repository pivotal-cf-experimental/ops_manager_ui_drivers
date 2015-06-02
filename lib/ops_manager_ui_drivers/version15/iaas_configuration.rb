module OpsManagerUiDrivers
  module Version15
    class IaasConfiguration
      def initialize(browser:)
        @browser = browser
      end

      def open_form
        browser.visit '/'
        browser.click_on 'show-microbosh-configure-action'
        browser.click_on 'show-iaas_configuration-action'
      end

      def save_form
        browser.click_on 'Save'
        browser.expect(browser.page).to browser.have_css('.flash-message.success')
      end

      def set_field(field, value)
        browser.find_field("iaas_configuration[#{field}]").set(value)
      end

      private

      attr_reader :browser
    end
  end
end
