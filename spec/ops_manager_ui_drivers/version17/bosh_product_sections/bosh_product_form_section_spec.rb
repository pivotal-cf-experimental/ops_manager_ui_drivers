require 'spec_helper'
require 'capybara'
require 'capybara/rspec/matchers'

module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      describe BoshProductFormSection do
        class FakeCapybaraExampleGroup < RSpec::Core::ExampleGroup
        end

        let(:browser) { instance_double(FakeCapybaraExampleGroup) }
        let(:expectation_target) { instance_double(RSpec::Expectations::ExpectationTarget, to: nil) }

        subject(:bosh_product_form_section) { BoshProductFormSection.new(browser, 'field-prefix') }

        describe '#open_form' do
          it 'opens the given form in the p-bosh tile' do
            expect(browser).to receive(:visit).with('/').ordered
            expect(browser).to receive(:click_on).with('show-p-bosh-configure-action').ordered
            expect(browser).to receive(:click_on).with('show-SOME_FORM-action').ordered

            bosh_product_form_section.open_form('SOME_FORM')
          end
        end

        describe '#save_form' do
          it 'saves the open form' do
            page           = double(:page)
            flash_selector = double(:flash_selector)
            allow(browser).to receive(:page).and_return(page)
            allow(browser).to receive(:have_css).with('.flash-message.success').and_return(flash_selector)

            expect(browser).to receive(:click_on).with('Save')
            expect(browser).to receive(:expect).with(page).and_return(expectation_target)
            expect(expectation_target).to receive(:to).with(flash_selector)
            bosh_product_form_section.save_form
          end
        end

        describe '#set_fields' do
          it 'iterates over and sets each field' do
            fields = {
              'field-A' => 'value-A',
              'field-B' => 'value-B',
            }

            field_A = double(:field, set: nil)
            field_B = double(:field, set: nil)

            allow(browser).to receive(:all).with(:field, 'field-prefix[field-A]', minimum: 1).and_return([field_A])
            allow(browser).to receive(:all).with(:field, 'field-prefix[field-B]', minimum: 1).and_return([field_B])

            expect(field_A).to receive(:set).with('value-A')
            expect(field_B).to receive(:set).with('value-B')
            bosh_product_form_section.set_fields(fields)
          end

          it 'sets the last field' do
            fields = {
              'field-A' => 'value-A',
            }

            field_A         = double(:field, set: nil)
            another_field_A = double(:field, set: nil)

            allow(browser).to receive(:all).with(:field, 'field-prefix[field-A]', minimum: 1).and_return([field_A, another_field_A])

            expect(another_field_A).to receive(:set).with('value-A')
            bosh_product_form_section.set_fields(fields)
          end
        end
      end
    end
  end
end

