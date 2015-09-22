module OpsManagerUiDrivers
  module Version16
    module BoshProductSections
      class AvailabilityZones
        def initialize(browser:)
          @browser = browser
          @bosh_product_form_section = BoshProductFormSection.new(browser, 'availability_zones[availability_zones][]')
        end

        def add_single_az(iaas_identifier)
          @bosh_product_form_section.open_form('availability_zones')
          @bosh_product_form_section.set_fields('iaas_identifier' => iaas_identifier)
          @bosh_product_form_section.save_form
        end

        def add_az(fields)
          @bosh_product_form_section.open_form('availability_zones')
          browser.click_on 'Add'
          @bosh_product_form_section.set_fields(fields)
          @bosh_product_form_section.save_form
        end

        private

        attr_reader :browser
      end
    end
  end
end
