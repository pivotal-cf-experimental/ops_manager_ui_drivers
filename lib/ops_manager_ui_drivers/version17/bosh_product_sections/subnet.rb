module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      class Subnet
        FLASH_MESSAGE_CLASS  = '.flash-message'.freeze
        FLASH_MESSAGE_ERRORS = '.flash-message.error ul.message li'.freeze

        def initialize(browser:, network_form:)
          @browser                   = browser
          @bosh_product_form_section = BoshProductFormSection.new(@browser, "#{network_form.field_prefix}[subnets][0]")
        end

        def add_subnet(iaas_identifier:, subnet:, dns:, gateway:, reserved_ip_ranges:)
          @bosh_product_form_section.set_fields(
            'iaas_identifier'    => iaas_identifier,
            'cidr'               => subnet,
            'dns'                => dns,
            'gateway'            => gateway,
            'reserved_ip_ranges' => reserved_ip_ranges,
          )
          @bosh_product_form_section.select_all_az_references_on_page
        end
      end
    end
  end
end
