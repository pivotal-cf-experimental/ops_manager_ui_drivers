require 'ops_manager_ui_drivers/version17/bosh_product_sections/networks'

module OpsManagerUiDrivers
  module Version18
    module BoshProductSections
      class Networks < Version17::BoshProductSections::Networks
        def add_network(name:, is_service_network:, subnets:)
          @bosh_product_form_section.open_form('network')

          @browser.click_on 'Add Network'
          @bosh_product_form_section.set_fields('name' => name, 'service_network' => is_service_network)

          subnets.each_with_index do |subnet, index|
            subnet_section = Subnet.new(browser: @browser, network_form: @bosh_product_form_section, subnet_index: index)
            subnet_section.add_subnet(**subnet.symbolize_keys)
          end

          @browser.click_on 'Save'
          @browser.expect(@browser.page).to @browser.have_css(FLASH_MESSAGE_CLASS)
          flash_errors = @browser.all(FLASH_MESSAGE_ERRORS).to_a
          flash_errors.reject! { |node| node.text =~ /cannot reach gateway/i }

          if (flash_errors.length > 0)
            fail flash_errors.collect(&:text).inspect
          end
        end
      end
    end
  end
end
