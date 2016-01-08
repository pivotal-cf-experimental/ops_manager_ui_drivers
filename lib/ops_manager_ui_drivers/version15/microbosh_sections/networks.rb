module OpsManagerUiDrivers
  module Version15
    module MicroboshSections
      class Networks
        def initialize(browser:)
          @browser                = browser
          @microbosh_form_section = MicroboshFormSection.new(browser, 'network[networks][]')
        end

        def add_single_network(name:, iaas_network_identifier:, subnet:, dns:, gateway:, reserved_ip_ranges:)
          @microbosh_form_section.open_form('network')

          @microbosh_form_section.set_fields(
            'name'                    => name,
            'iaas_network_identifier' => iaas_network_identifier,
            'subnet'                  => subnet,
            'dns'                     => dns,
            'gateway'                 => gateway,
            'reserved_ip_ranges'      => reserved_ip_ranges,
          )
          browser.click_on 'Save'
          flash_errors = browser.all('.flash-message.error ul.message li').to_a
          flash_errors.reject! { |node| node.text =~ /cannot reach gateway/i }

          if (flash_errors.length > 0)
            fail flash_errors.collect(&:text).inspect
          end
        end

        def add_network(name:, iaas_network_identifier:, subnet:, dns:, gateway:, reserved_ip_ranges:)
          @microbosh_form_section.open_form('network')

          browser.click_on 'Add'
          @microbosh_form_section.set_fields(
            'name'                    => name,
            'iaas_network_identifier' => iaas_network_identifier,
            'subnet'                  => subnet,
            'dns'                     => dns,
            'gateway'                 => gateway,
            'reserved_ip_ranges'      => reserved_ip_ranges,
          )
          @microbosh_form_section.save_form
        end

        private

        attr_reader :browser
      end
    end
  end
end
