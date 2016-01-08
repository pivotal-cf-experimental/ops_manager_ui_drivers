module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      class Networks
        FLASH_MESSAGE_CLASS  = '.flash-message'.freeze
        FLASH_MESSAGE_ERRORS = '.flash-message.error ul.message li'.freeze

        def initialize(browser:)
          @browser                   = browser
          @bosh_product_form_section = BoshProductFormSection.new(@browser, 'network_collection[networks_attributes][0]')
        end

        def add_network(name:, iaas_network_identifier:, subnet:, dns:, gateway:, reserved_ip_ranges:)
          @bosh_product_form_section.open_form('network')

          @browser.click_on 'Add Network'
          @bosh_product_form_section.set_fields('name' => name)

          subnet_section = Subnet.new(browser: @browser, network_form: @bosh_product_form_section)
          subnet_section.add_subnet(iaas_identifier: iaas_network_identifier, subnet: subnet, dns: dns, gateway: gateway, reserved_ip_ranges: reserved_ip_ranges)

          @browser.click_on 'Save'
          @browser.expect(@browser.page).to @browser.have_css(FLASH_MESSAGE_CLASS)
          flash_errors = @browser.all(FLASH_MESSAGE_ERRORS).to_a
          flash_errors.reject! { |node| node.text =~ /cannot reach gateway/i }

          if (flash_errors.length > 0)
            fail flash_errors.collect(&:text).inspect
          end
        end

        def delete_network(network_name)
          @bosh_product_form_section.open_form('network')
          button = @browser.find('button', text: network_name)
          button.click
          button.find(:xpath, '..').first('.with-delete-record').trigger('click')

          @bosh_product_form_section.save_form
        end
      end
    end
  end
end
