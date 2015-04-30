module OpsManagerUiDrivers
  module Version13
    class Networks
      def initialize(browser:, product:)
        @browser = browser
        @product = product

        @allowed_ignorable_errors = []
      end

      def add_network(name:, iaas_network_identifier:, subnet:, dns:, gateway:, reserved_ip_ranges:)
        open_form('network')

        browser.click_on 'Add'
        set_fields(
          fields: {
            'name' => name,
            'iaas_network_identifier' => iaas_network_identifier,
            'subnet' => subnet,
            'dns' => dns,
            'gateway' => gateway,
            'reserved_ip_ranges' => reserved_ip_ranges,
          }
        )

        allow_network_not_found_errors
        save_form
      end

      private

      attr_reader :browser, :product

      def allow_network_not_found_errors
        network_not_found = /not found in datacenter/
        return if @allowed_ignorable_errors.include?(network_not_found)

        @allowed_ignorable_errors << network_not_found
      end

      def expect_allowed_ignorable_errors
        flash_errors = browser.all('.flash-message.error')

        if flash_errors.any?
          unexpected_errors = flash_errors.reject do |error|
            @allowed_ignorable_errors.select do |expected_error|
              error.text =~ expected_error
            end.any?
          end

          fail "Unexepcted ignorable errors: #{unexpected_errors.map(&:text).inspect}" unless unexpected_errors.empty?
        else
          browser.expect(browser.page).to browser.have_css('.flash-message.success')
        end
      end

      def save_form
        browser.click_on 'Save'
        expect_allowed_ignorable_errors
      end

      def open_form(form)
        browser.visit '/'
        browser.click_on "show-#{product}-configure-action"
        browser.click_on "show-#{form}-action"
      end

      def set_fields(fields:)
        fields.each do |field, value|
          set_field(field, value)
        end
      end

      def set_field(field, value)
        last_field(field).set(value)
      end

      def last_field(field)
        browser.all(:field, "network[networks][][#{field}]").last
      end
    end
  end
end
