module OpsManagerUiDrivers
  module Version15
    module MicroboshSections
      class IaasConfiguration
        def initialize(browser:)
          @microbosh_form_section = MicroboshFormSection.new(browser, 'iaas_configuration')
        end

        def fill_iaas_settings(fields)
          @microbosh_form_section.open_form('iaas_configuration')
          @microbosh_form_section.set_fields(fields)
          @microbosh_form_section.save_form
        end
      end
    end
  end
end
