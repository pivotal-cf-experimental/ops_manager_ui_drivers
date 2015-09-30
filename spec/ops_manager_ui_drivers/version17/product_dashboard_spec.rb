require 'spec_helper'
require 'capybara'

module OpsManagerUiDrivers
  module Version17
    describe ProductDashboard do
      describe '#product_complete?' do
        let(:product_dashboard) { OpsManagerUiDrivers::Version17::ProductDashboard.new(browser: browser) }
        let(:browser) { double('browser') }

        before do
          allow(browser).to receive(:visit)
        end

        it 'returns true when complete' do
          expect(browser).to receive(:all).with("a#show-p-bosh-configure-action[data-progress='100']").and_return([instance_double(Capybara::Node)])
          expect(product_dashboard.product_complete?('p-bosh')).to eq(true)
        end

        it 'returns false when incomplete' do
          expect(browser).to receive(:all).with("a#show-p-bosh-configure-action[data-progress='100']").and_return([])
          expect(product_dashboard.product_complete?('p-bosh')).to eq(false)
        end
      end
    end
  end
end
