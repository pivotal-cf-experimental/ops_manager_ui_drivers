require 'spec_helper'
require 'capybara'
require 'capybara/rspec/matchers'

module OpsManagerUiDrivers
  module Version16
    module BoshProductSections
      RSpec.describe AdvancedInfrastructureConfig do
        class FakeCapybaraExampleGroup < RSpec::Core::ExampleGroup
        end

        let(:browser) { instance_double(FakeCapybaraExampleGroup) }
        let(:bosh_product_form_section) { instance_double(BoshProductFormSection) }

        subject(:advanced_infrastructure_config) { AdvancedInfrastructureConfig.new(browser: browser) }

        before do
          allow(BoshProductFormSection).to receive(:new).with(browser, 'advanced_infrastructure_config').and_return(bosh_product_form_section)
        end

        describe '#fill_advanced_infrastructure_config_settings' do
          it 'opens the iaas_configuration, fills out the fields and saves the form' do
            expect(bosh_product_form_section).to receive(:open_form).with('advanced_infrastructure_config')
            expect(bosh_product_form_section).to receive(:set_fields).with({'connection_options' => 'some_text'})
            expect(bosh_product_form_section).to receive(:save_form)
            advanced_infrastructure_config.fill_advanced_infrastructure_config_settings({'connection_options' => 'some_text'})
          end

          it 'does not open the advanced_infrastructure_config form if the provided fields are empty' do
            expect(bosh_product_form_section).not_to receive(:open_form).with('advanced_infrastructure_config')
            advanced_infrastructure_config.fill_advanced_infrastructure_config_settings({})
          end
        end
      end
    end
  end
end
