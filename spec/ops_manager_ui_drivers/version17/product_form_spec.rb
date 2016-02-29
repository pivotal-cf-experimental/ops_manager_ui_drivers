require 'spec_helper'
module OpsManagerUiDrivers
  module Version17
    describe ProductForm do
      describe '#fill_in_selector_property' do
        let(:product_form) {
          OpsManagerUiDrivers::Version17::ProductForm.new(
            browser:      browser,
            product_name: 'product_name',
            form_name:    'form_name',
          )
        }
        let(:browser) { double('browser') }
        let(:radio_button) { double('radio_button') }

        before do
          allow(browser).to receive(:first).and_return(radio_button)
          allow(radio_button).to receive(:click)
        end

        it 'finds and clicks the specified radio button' do
          expect(browser).to receive(:first)
                               .with(%Q(input[type="radio"][name="form_name[.properties.selector_property][value]"][value="value_external"]))
                               .and_return(radio_button)

          expect(radio_button).to receive(:click)
          product_form.fill_in_selector_property(
            selector_input_reference: '.properties.selector_property',
            selector_name:            'name_external',
            selector_value:           'value_external',
            sub_field_answers:        {},
          )
        end

        context 'when sub_field_answers is an empty hash' do
          it 'does not fill in any fields' do
            product_form.fill_in_selector_property(
              selector_input_reference: '.properties.selector_property',
              selector_name:            'name_external',
              selector_value:           'value_external',
              sub_field_answers:        {},
            )
          end
        end

        context 'when sub_field_answers has values for simple properties' do
          let(:field_1) { double('field_1') }
          let(:field_2) { double('field_2') }

          it 'fills in each field with the specified value' do
            expect(browser).to receive(:find_field)
                                 .with('form_name[.properties.selector_property][name_external][label_1]')
                                 .and_return(field_1)
            expect(browser).to receive(:find_field)
                                 .with('form_name[.properties.selector_property][name_external][label_2]')
                                 .and_return(field_2)

            expect(field_1).to receive(:set).with('value_1')
            expect(field_2).to receive(:set).with('value_2')

            product_form.fill_in_selector_property(
              selector_input_reference: '.properties.selector_property',
              selector_name:            'name_external',
              selector_value:           'value_external',
              sub_field_answers:        {
                'label_1' => {attribute_value: 'value_1'},
                'label_2' => {attribute_value: 'value_2'},
              },
            )
          end
        end

        context 'when sub_field_answers has a value for a secret field' do
          let(:field_1) { double('field_1') }
          let(:field_2) { double('field_2') }

          it 'fills in the secret field with the specified value' do
            expect(browser).to receive(:find_field)
                                 .with('form_name[.properties.selector_property][name_external][label][secret]')
                                 .and_return(field_1)

            expect(field_1).to receive(:set).with('value')

            product_form.fill_in_selector_property(
              selector_input_reference: '.properties.selector_property',
              selector_name:            'name_external',
              selector_value:           'value_external',
              sub_field_answers:        {
                'label' => {
                  attribute_name:  'secret',
                  attribute_value: 'value',
                }
              },
            )
          end
        end
      end
    end
  end
end
