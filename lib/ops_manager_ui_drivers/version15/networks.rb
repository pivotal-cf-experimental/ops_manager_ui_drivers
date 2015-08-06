module OpsManagerUiDrivers
  module Version15
    class Networks
      def initialize(browser:)
        @browser = browser
      end

      def add_single_network(name:, iaas_network_identifier:, subnet:, dns:, gateway:, reserved_ip_ranges:)
        open_form('network')

        set_fields(
          'name' => name,
          'iaas_network_identifier' => iaas_network_identifier,
          'subnet' => subnet,
          'dns' => dns,
          'gateway' => gateway,
          'reserved_ip_ranges' => reserved_ip_ranges,
        )
        browser.click_on 'Save'
        flash_errors = browser.all('.flash-message.error ul.message li').to_a
        flash_errors.reject! { |node| node.text =~ /cannot reach gateway/i }

        if (flash_errors.length > 0)
          fail flash_errors.collect(&:text).inspect
        end
      end

      def add_network(name:, iaas_network_identifier:, subnet:, dns:, gateway:, reserved_ip_ranges:)
        open_form('network')

        browser.click_on 'Add'
        set_fields(
          'name' => name,
          'iaas_network_identifier' => iaas_network_identifier,
          'subnet' => subnet,
          'dns' => dns,
          'gateway' => gateway,
          'reserved_ip_ranges' => reserved_ip_ranges,
        )
        save_form
      end

      private

      attr_reader :browser

      def save_form
        browser.click_on 'Save'
        browser.expect(browser.page).to browser.have_css('.flash-message.success')
      end

      def open_form(form)
        browser.visit '/'
        browser.click_on 'show-microbosh-configure-action'
        browser.click_on "show-#{form}-action"
      end

      def set_fields(fields)
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
