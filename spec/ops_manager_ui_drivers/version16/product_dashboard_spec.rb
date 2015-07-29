require 'spec_helper'
require 'capybara'

module OpsManagerUiDrivers
  module Version16
    describe ProductDashboard do
      describe '#product_complete?' do
        let(:product_dashboard) { OpsManagerUiDrivers::Version16::ProductDashboard.new(browser: browser) }
        let(:browser) { double('browser') }

        before do
          allow(browser).to receive(:visit)
        end

        it 'returns true when complete' do
          expect(browser).to receive(:all).with("a#show-microbosh-configure-action[data-progress='100']").and_return([instance_double(Capybara::Node)])
          expect(product_dashboard.product_complete?('microbosh')).to eq(true)
        end

        it 'returns false when incomplete' do
          expect(browser).to receive(:all).with("a#show-microbosh-configure-action[data-progress='100']").and_return([])
          expect(product_dashboard.product_complete?('microbosh')).to eq(false)
        end
      end
    end
  end
end
