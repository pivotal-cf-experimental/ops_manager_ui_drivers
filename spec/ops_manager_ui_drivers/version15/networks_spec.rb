require 'spec_helper'
require 'capybara'
require 'capybara/rspec/matchers'
require 'recursive-open-struct'

module OpsManagerUiDrivers
  module Version15
    RSpec.describe Networks do
      class FakeCapybaraExampleGroup < RSpec::Core::ExampleGroup
        include Capybara::DSL
        include Capybara::RSpecMatchers
        include OpsManagerUiDrivers::WaitHelper
      end

      let(:browser) { instance_double(FakeCapybaraExampleGroup) }
      let(:expectation_target) { instance_double(RSpec::Expectations::ExpectationTarget, to: nil) }
      let(:field_node) { instance_double(Capybara::Node::Element, set: nil) }

      subject(:networks) { Networks.new(browser: browser) }

      before do
        allow(browser).to receive(:visit)
        allow(browser).to receive(:all).and_return([field_node])
        allow(browser).to receive(:page)
        allow(browser).to receive(:expect).and_return(expectation_target)
        allow(browser).to receive(:click_on)
        allow(browser).to receive(:have_css)
      end

      describe '#add_network' do
        it 'navigates to the root-page, microbosh-product, iaas-configuration page, and sets the iaas-identifier' do
          page = double(:page)
          flash_selector = double(:flash_selector)
          allow(browser).to receive(:page).and_return(page)
          allow(browser).to receive(:have_css).with('.flash-message.success').and_return(flash_selector)

          networks.add_network(
            name: 'Name',
            iaas_network_identifier: 'IaasNetworkIdentifier',
            subnet: 'Subnet',
            dns: 'Dns',
            gateway: 'Gateway',
            reserved_ip_ranges: 'ReservedIpRanges',
          )

          expect(browser).to have_received(:visit).with('/').ordered
          expect(browser).to have_received(:click_on).with('show-microbosh-configure-action').ordered
          expect(browser).to have_received(:click_on).with('show-network-action').ordered

          expect(browser).to have_received(:all).with(:field, 'network[networks][][name]').ordered
          expect(field_node).to have_received(:set).with('Name').ordered

          expect(browser).to have_received(:all).with(:field, 'network[networks][][iaas_network_identifier]').ordered
          expect(field_node).to have_received(:set).with('IaasNetworkIdentifier').ordered

          expect(browser).to have_received(:all).with(:field, 'network[networks][][subnet]').ordered
          expect(field_node).to have_received(:set).with('Subnet').ordered

          expect(browser).to have_received(:all).with(:field, 'network[networks][][dns]').ordered
          expect(field_node).to have_received(:set).with('Dns').ordered

          expect(browser).to have_received(:all).with(:field, 'network[networks][][gateway]').ordered
          expect(field_node).to have_received(:set).with('Gateway').ordered

          expect(browser).to have_received(:all).with(:field, 'network[networks][][reserved_ip_ranges]').ordered
          expect(field_node).to have_received(:set).with('ReservedIpRanges').ordered

          expect(browser).to have_received(:click_on).with('Save').ordered
          expect(browser).to have_received(:expect).with(page).ordered
          expect(expectation_target).to have_received(:to).with(flash_selector).ordered
        end
      end
    end
  end
end
