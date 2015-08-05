require 'spec_helper'
require 'capybara'
require 'capybara/rspec/matchers'
require 'recursive-open-struct'

module OpsManagerUiDrivers
  module Version16
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
        allow(browser).to receive(:click_on)
        allow(browser).to receive(:find_field).and_return(field_node)
        allow(browser).to receive(:page)
        allow(browser).to receive(:expect).and_return(expectation_target)
        allow(browser).to receive(:have_css)
      end

      describe '#open_form' do
        it 'navigates to the root-page, microbosh-product, and then iaas-configuration page' do
          iaas_configuration.open_form

          expect(browser).to have_received(:visit).with('/').ordered
          expect(browser).to have_received(:click_on).with('show-microbosh-configure-action').ordered
          expect(browser).to have_received(:click_on).with('show-iaas_configuration-action').ordered
        end
      end

      describe '#save_form' do
        it 'clicks save and validates that a success flash was shown' do
          page = double(:page)
          flash_selector = double(:flash_selector)
          allow(browser).to receive(:page).and_return(page)
          allow(browser).to receive(:have_css).with('.flash-message.success').and_return(flash_selector)

          iaas_configuration.save_form

          expect(browser).to have_received(:click_on).with('Save').ordered
          expect(browser).to have_received(:expect).with(page).ordered
          expect(expectation_target).to have_received(:to).with(flash_selector).ordered
        end
      end

      describe '#set_field' do
        it 'finds the indicated field and sets the provided value' do
          iaas_configuration.set_field('field-name', 'some-value')

          expect(browser).to have_received(:find_field).with('iaas_configuration[field-name]').ordered
          expect(field_node).to have_received(:set).with('some-value').ordered
        end
      end
    end
  end
end
