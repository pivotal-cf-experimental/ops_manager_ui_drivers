require 'spec_helper'
require 'capybara'
require 'capybara/rspec/matchers'
require 'recursive-open-struct'

module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      RSpec.describe Networks do
        class FakeCapybaraExampleGroup < RSpec::Core::ExampleGroup
          include Capybara::DSL
          include Capybara::RSpecMatchers
          include OpsManagerUiDrivers::WaitHelper
        end

        let(:browser) { instance_double(FakeCapybaraExampleGroup) }
        let(:expectation_target) { instance_double(RSpec::Expectations::ExpectationTarget, to: nil) }
        let(:field_node) { instance_double(Capybara::Node::Element, set: nil) }
        let(:delete_button) { double('delete button') }
        let(:page) { double(:page) }
        let(:flash_selector) {double(:flash_selector)}


        subject(:networks) { Networks.new(browser: browser) }

        before do
          allow(browser).to receive(:visit)
          allow(browser).to receive(:all).and_return([field_node])
          allow(browser).to receive(:page)
          allow(browser).to receive(:click_on)
          allow(browser).to receive(:have_css)
          allow(browser).to receive(:find).and_return(delete_button)
          allow(browser).to receive(:page).and_return(page)
          allow(browser).to receive(:have_css).with('.flash-message.success').and_return(flash_selector)
          allow(browser).to receive(:have_css).with('.flash-message').and_return(flash_selector)
          allow(browser).to receive(:expect).and_return(expectation_target)
        end

        describe '#add_network' do
          it 'fails when there are unexpected errors' do
            error = double(:error, text: 'error_message')
            unexpected_errors = [error]
            allow(browser).to receive(:all).with('.flash-message.error ul.message li').and_return(unexpected_errors)
            expect_any_instance_of(BoshProductFormSection).to receive(:select_all_az_references_on_page)

            expect { networks.add_network(
              name: 'Name',
              iaas_network_identifier: 'IaasNetworkIdentifier',
              subnet: 'Subnet',
              dns: 'Dns',
              gateway: 'Gateway',
              reserved_ip_ranges: 'ReservedIpRanges',
            ) }.to raise_error(/error_message/)
          end

          it 'does not fail on icmp errors' do
            error = double(:error, text: 'cannot reach gateway')
            unexpected_errors = [error]
            allow(browser).to receive(:all).with('.flash-message.error ul.message li').and_return(unexpected_errors)

            expect { networks.add_network(
              name: 'Name',
              iaas_network_identifier: 'IaasNetworkIdentifier',
              subnet: 'Subnet',
              dns: 'Dns',
              gateway: 'Gateway',
              reserved_ip_ranges: 'ReservedIpRanges',
            ) }.not_to raise_error
          end

          it 'navigates to the root-page > p-bosh configuration > configure networks page > and sets the network fields' do
            allow(browser).to receive(:all).with('.flash-message.error ul.message li').and_return([])

            networks.add_network(
              name: 'Name',
              iaas_network_identifier: 'IaasNetworkIdentifier',
              subnet: 'Subnet',
              dns: 'Dns',
              gateway: 'Gateway',
              reserved_ip_ranges: 'ReservedIpRanges',
            )

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-p-bosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-network-action').ordered
            expect(browser).to have_received(:click_on).with('Add').ordered

            expect(browser).to have_received(:all).with(:field, 'network_collection[networks_attributes][0][name]', minimum: 1).ordered
            expect(field_node).to have_received(:set).with('Name').ordered

            expect(browser).to have_received(:all).with(:field, 'network_collection[networks_attributes][0][subnets][0][iaas_identifier]', minimum: 1).ordered
            expect(field_node).to have_received(:set).with('IaasNetworkIdentifier').ordered

            expect(browser).to have_received(:all).with(:field, 'network_collection[networks_attributes][0][subnets][0][cidr]', minimum: 1).ordered
            expect(field_node).to have_received(:set).with('Subnet').ordered

            expect(browser).to have_received(:all).with(:field, 'network_collection[networks_attributes][0][subnets][0][dns]', minimum: 1).ordered
            expect(field_node).to have_received(:set).with('Dns').ordered

            expect(browser).to have_received(:all).with(:field, 'network_collection[networks_attributes][0][subnets][0][gateway]', minimum: 1).ordered
            expect(field_node).to have_received(:set).with('Gateway').ordered

            expect(browser).to have_received(:all).with(:field, 'network_collection[networks_attributes][0][subnets][0][reserved_ip_ranges]', minimum: 1).ordered
            expect(field_node).to have_received(:set).with('ReservedIpRanges').ordered

            expect(browser).to have_received(:click_on).with('Save').ordered
            expect(browser).to have_received(:expect).with(page).ordered
            expect(expectation_target).to have_received(:to).with(flash_selector).ordered
          end
        end

        describe '#delete_network' do
          before do
            allow(delete_button).to receive(:trigger).with('click')
          end

          it 'navigates to the root-page > p-bosh configuration > configure networks page > and deletes the specified network' do
            networks.delete_network('Name')

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-p-bosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-network-action').ordered
            expect(browser).to have_received(:find).with("i[id='delete-Name']").ordered

            expect(browser).to have_received(:click_on).with('Save').ordered
            expect(browser).to have_received(:expect).with(page).ordered
            expect(expectation_target).to have_received(:to).with(flash_selector).ordered
          end
        end
      end
    end
  end
end
