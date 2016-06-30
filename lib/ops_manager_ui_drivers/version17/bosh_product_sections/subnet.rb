module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      class Subnet
        FLASH_MESSAGE_CLASS  = '.flash-message'.freeze
        FLASH_MESSAGE_ERRORS = '.flash-message.error ul.message li'.freeze

        def initialize(browser:, network_form:, subnet_index:)
          @browser                   = browser
          @subnet_index = subnet_index
          @subnet_form_section =
            BoshProductFormSection.new(@browser, "#{network_form.field_prefix}[subnets][#{subnet_index}]")
        end

        def add_subnet(identifier:, cidr:, dns:, gateway:, reserved_ips:, availability_zones:)
          @browser.all('a', text: 'Add Subnet').last.click if @subnet_index > 0

          @subnet_form_section.set_fields(
            'iaas_identifier'    => identifier,
            'cidr'               => cidr,
            'dns'                => dns,
            'gateway'            => gateway,
            'reserved_ip_ranges' => reserved_ips,
          )

          availability_zones.each do |availability_zone|
            @browser.
              find(:xpath, %Q{//label/input[contains(@name, "#{@subnet_form_section.field_prefix}[availability_zone_references]")]/..}, text: availability_zone).click
          end
        end
      end
    end
  end
end
