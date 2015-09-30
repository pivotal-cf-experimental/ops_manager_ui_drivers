module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      class IaasConfiguration
        def initialize(browser:)
          @bosh_product_form_section = BoshProductFormSection.new(browser, 'iaas_configuration')
        end

        def fill_iaas_settings(fields)
          @bosh_product_form_section.open_form('iaas_configuration')
          @bosh_product_form_section.set_fields(fields)
          @bosh_product_form_section.save_form
        end
      end
    end
  end
end
