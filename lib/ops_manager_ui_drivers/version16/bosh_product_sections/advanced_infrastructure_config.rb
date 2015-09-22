module OpsManagerUiDrivers
  module Version16
    module BoshProductSections
      class AdvancedInfrastructureConfig
        def initialize(browser:)
          @bosh_product_form_section = BoshProductFormSection.new(browser, 'advanced_infrastructure_config')
        end

        def fill_advanced_infrastructure_config_settings(fields)
          return if fields.empty?
          @bosh_product_form_section.open_form('advanced_infrastructure_config')
          @bosh_product_form_section.set_fields(fields)
          @bosh_product_form_section.save_form
        end
      end
    end
  end
end
