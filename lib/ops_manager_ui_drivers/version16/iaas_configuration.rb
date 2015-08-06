module OpsManagerUiDrivers
  module Version16
    class IaasConfiguration
      def initialize(browser:)
        @browser = browser
      end

      def fill_iaas_settings(fields)
        open_form
        fields.each do |name, value|
          set_field(name, value)
        end
        save_form
      end

      private

      attr_reader :browser

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
    end
  end
end
