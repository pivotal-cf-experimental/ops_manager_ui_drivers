module OpsManagerUiDrivers
  module Version15
    module MicroboshSections
      class AvailabilityZones
        def initialize(browser:)
          @browser = browser
          @microbosh_form_section = MicroboshFormSection.new(browser, 'availability_zones[availability_zones][]')
        end

        def add_single_az(iaas_identifier)
          @microbosh_form_section.open_form('availability_zones')
          @microbosh_form_section.set_fields('iaas_identifier' => iaas_identifier)
          @microbosh_form_section.save_form
        end

        def add_az(fields)
          @microbosh_form_section.open_form('availability_zones')
          browser.click_on 'Add'
          @microbosh_form_section.set_fields(fields)
          @microbosh_form_section.save_form
        end

        private

        attr_reader :browser
      end
    end
  end
end
