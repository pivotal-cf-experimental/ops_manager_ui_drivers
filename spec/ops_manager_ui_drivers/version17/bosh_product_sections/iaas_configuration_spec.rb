require 'spec_helper'
require 'capybara/dsl'
require 'capybara/rspec/matchers'

module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      RSpec.describe IaasConfiguration do
        class FakeCapybaraExampleGroup < RSpec::Core::ExampleGroup
          include Capybara::DSL
          include Capybara::RSpecMatchers
          include OpsManagerUiDrivers::WaitHelper
        end

        let(:browser) { instance_double(FakeCapybaraExampleGroup) }
        let(:expectation_target) { instance_double(RSpec::Expectations::ExpectationTarget, to: nil) }
        let(:field_node) { instance_double(Capybara::Node::Element, set: nil) }

        subject(:iaas_configuration) { IaasConfiguration.new(browser: browser) }

        before do
          allow(browser).to receive(:visit)
          allow(browser).to receive(:all).and_return([field_node])
          allow(browser).to receive(:page)
          allow(browser).to receive(:click_on)
          allow(browser).to receive(:expect).and_return(expectation_target)
          allow(browser).to receive(:have_css)
          allow(browser).to receive(:execute_script)
        end

        describe '#fill_iaas_settings' do
          it 'opens the iaas_configuration, fills out the fields and saves the form' do
            page           = double(:page)
            flash_selector = double(:flash_selector)
            allow(browser).to receive(:page).and_return(page)
            allow(browser).to receive(:have_css).with('.flash-message.success').and_return(flash_selector)

            iaas_configuration.fill_iaas_settings(
              'field_name'       => 'field-value',
              'other_field_name' => 'other-field-value',
            )

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-p-bosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-iaas_configuration-action').ordered

            expect(browser).to have_received(:all).with(:field, 'iaas_configuration[field_name]', minimum: 1).ordered
            expect(field_node).to have_received(:set).with('field-value').ordered

            expect(browser).to have_received(:all).with(:field, 'iaas_configuration[other_field_name]', minimum: 1).ordered
            expect(field_node).to have_received(:set).with('other-field-value').ordered

            expect(browser).to have_received(:click_on).with('Save').ordered
            expect(browser).to have_received(:expect).with(page).ordered
            expect(expectation_target).to have_received(:to).with(flash_selector).ordered
          end
        end
      end
    end
  end
end
