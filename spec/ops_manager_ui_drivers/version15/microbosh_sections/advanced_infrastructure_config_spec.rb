require 'spec_helper'
require 'capybara'
require 'capybara/rspec/matchers'
require 'recursive-open-struct'

module OpsManagerUiDrivers
  module Version15
    module MicroboshSections
      RSpec.describe AdvancedInfrastructureConfig do
        class FakeCapybaraExampleGroup < RSpec::Core::ExampleGroup
          include Capybara::DSL
          include Capybara::RSpecMatchers
          include OpsManagerUiDrivers::WaitHelper
        end

        let(:browser) { instance_double(FakeCapybaraExampleGroup) }
        let(:microbosh_form_section) { instance_double(MicroboshFormSection) }

        subject(:advanced_infrastructure_config) { AdvancedInfrastructureConfig.new(browser: browser) }

        before do
          allow(MicroboshFormSection).to receive(:new).with(browser, 'advanced_infrastructure_config').and_return(microbosh_form_section)
        end

        describe '#fill_advanced_infrastructure_config_settings' do
          it 'opens the iaas_configuration, fills out the fields and saves the form' do
            expect(microbosh_form_section).to receive(:open_form).with('advanced_infrastructure_config')
            expect(microbosh_form_section).to receive(:set_fields).with({'connection_options' => 'some_text'})
            expect(microbosh_form_section).to receive(:save_form)
            advanced_infrastructure_config.fill_advanced_infrastructure_config_settings({'connection_options' => 'some_text'})
          end

          it 'does not open the advanced_infrastructure_config form if the provided fields are empty' do
            expect(microbosh_form_section).not_to receive(:open_form).with('advanced_infrastructure_config')
            advanced_infrastructure_config.fill_advanced_infrastructure_config_settings({})
          end
        end
      end
    end
  end
end
