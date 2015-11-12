module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      class Networks
        def initialize(browser:)
          @browser = browser
          @bosh_product_form_section = BoshProductFormSection.new(browser, 'network_collection[networks_attributes][0]')
        end

        def add_single_network(name:, iaas_network_identifier:, subnet:, dns:, gateway:, reserved_ip_ranges:)
          @bosh_product_form_section.open_form('network')

          @bosh_product_form_section.set_fields(
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
          @bosh_product_form_section.open_form('network')

          browser.click_on 'Add'
          @bosh_product_form_section.set_fields(
            'name' => name,
            'iaas_network_identifier' => iaas_network_identifier,
            'subnet' => subnet,
            'dns' => dns,
            'gateway' => gateway,
            'reserved_ip_ranges' => reserved_ip_ranges,
          )
          @bosh_product_form_section.save_form
        end

        def delete_network(network_name)
          @bosh_product_form_section.open_form('network')
          button = browser.find("i[id='delete-#{network_name}']")
          button.trigger('click')

          @bosh_product_form_section.save_form
        end

        private

        attr_reader :browser
      end
    end
  end
end
