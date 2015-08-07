module OpsManagerUiDrivers
  module Version16
    module Sections
      class AdvancedInfrastructureConfig
        def initialize(browser:)
          @microbosh_form_section = MicroboshFormSection.new(browser, 'advanced_infrastructure_config')
        end

        def set_connection_options(connection_options)
          @microbosh_form_section.open_form('advanced_infrastructure_config')
          @microbosh_form_section.set_fields({'connection_options' => connection_options})
          @microbosh_form_section.save_form
        end
      end
    end
  end
end
