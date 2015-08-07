module OpsManagerUiDrivers
  module Version15
    module Sections
      class AdvancedInfrastructureConfig
        def initialize(browser:)
          @microbosh_form_section = MicroboshFormSection.new(browser, 'advanced_infrastructure_config')
        end

        def fill_advanced_infrastructure_config_settings(fields)
          return if fields.empty?
          @microbosh_form_section.open_form('advanced_infrastructure_config')
          @microbosh_form_section.set_fields(fields)
          @microbosh_form_section.save_form
        end
      end
    end
  end
end
