require 'spec_helper'
require 'capybara'

module OpsManagerUiDrivers
  module Version17
    describe ProductDashboard do
      let(:browser) { double('browser') }
      let(:product_dashboard) { OpsManagerUiDrivers::Version17::ProductDashboard.new(browser: browser) }
      before do
        allow(browser).to receive(:visit)
      end

      describe '#product_complete?' do
        it 'returns true when complete' do
          expect(browser).to receive(:all).with("a#show-p-bosh-configure-action[data-progress='100']").and_return([instance_double(Capybara::Node)])
          expect(product_dashboard.product_complete?('p-bosh')).to eq(true)
        end

        it 'returns false when incomplete' do
          expect(browser).to receive(:all).with("a#show-p-bosh-configure-action[data-progress='100']").and_return([])
          expect(product_dashboard.product_complete?('p-bosh')).to eq(false)
        end
      end

      describe '#delete_unused_products' do
        it 'clicks on the delete_unused_products link' do
          delete_products_link = double('delete products link')
          allow(delete_products_link).to receive(:trigger)
          allow(browser).to receive(:find).with('a#delete_unused_products').and_return(delete_products_link)

          product_dashboard.delete_unused_products

          expect(delete_products_link).to have_received(:trigger).with('click')
        end
      end
    end
  end
end
