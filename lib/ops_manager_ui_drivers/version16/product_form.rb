module OpsManagerUiDrivers
  module Version16
    class ProductForm
      def initialize(browser:, product_name:, form_name:)
        @browser = browser
        @product_name = product_name
        @form_name = form_name
      end

      def property(property_reference)
        browser.find_field("#{form_name}[#{property_reference}]")
      end

      def nested_property(property_reference, nested_reference)
        browser.find_field("#{form_name}[#{property_reference}][#{nested_reference}]")
      end

      def generate_self_signed_cert(wildcard_domain)
        browser.click_on 'Generate RSA Certificate'
        browser.within '#rsa-certificate-form' do
          browser.fill_in 'rsa_certificate[domains]', with: wildcard_domain
          browser.click_on 'save-rsa-certificate-action'
        end
      end

      def fill_in_selector_property(selector_input_reference:, selector_name:, selector_value:, sub_field_answers:)
        radio = browser.first(%Q(input[type="radio"][name="#{form_name}[#{selector_input_reference}][value]"][value="#{selector_value}"]))
        radio.click
        sub_field_answers.each do |label, value|
          selector_string = "#{form_name}[#{selector_input_reference}][#{selector_name}][#{label}]"

          if value[:attribute_name]
            selector_string += "[#{value[:attribute_name]}]"
          end

          browser.find_field(selector_string).set(value[:attribute_value])
        end
      end

      def save_form(validate: true)
        browser.click_on 'Save'

        fail('unexpected failure') unless browser.has_css?('.flash-message')

        if validate
          fail(browser.find('.flash-message.error').text) unless browser.has_css?('.flash-message.success')
        end
      end

      def open_form
        browser.visit '/'
        browser.click_on "show-#{product_name}-configure-action"
        browser.click_on "show-#{form_name}-action"
      end

      private

      attr_reader :browser, :product_name, :form_name
    end
  end
end
