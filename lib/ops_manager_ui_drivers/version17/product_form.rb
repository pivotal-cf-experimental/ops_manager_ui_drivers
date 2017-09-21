require 'ops_manager_ui_drivers/animation_helper'

module OpsManagerUiDrivers
  module Version17
    class ProductForm
      include AnimationHelper

      def initialize(browser:, product_name:, form_name:)
        @browser      = browser
        @product_name = product_name
        @form_name    = form_name
      end

      def property(property_reference)
        name = "#{form_name}[#{property_reference}]"
        browser.execute_script "$('a[data-masked-input-name=\"#{name}\"]:contains(\"Change\")').click()"
        browser.find_field(name)
      end

      def nested_property(property_reference, nested_reference)
        name = "#{form_name}[#{property_reference}][#{nested_reference}]"
        browser.execute_script "$('a[data-masked-input-name=\"#{name}\"]:contains(\"Change\")').click()"
        browser.find_field(name)
      end

      def select_option(property_reference:, option_value:)
        name = "#{form_name}" + property_reference.map {|field| "[#{field}]" }.join
        browser.find_field(name).find(:option, option_value).select_option
      end

      def generate_self_signed_cert(wildcard_domain, property_reference, selector_property_reference = nil, selector_option_name = nil)
        if selector_property_reference && selector_option_name
          private_key_field_name = "#{form_name}[#{selector_property_reference}][#{selector_option_name}][#{property_reference}][private_key_pem]"
        else
          private_key_field_name = "#{form_name}[#{property_reference}][private_key_pem]"
        end

        change_link = browser.first(%Q(a[data-masked-input-name="#{private_key_field_name}"]))
        change_link.click if change_link
        disable_css_transitions!

        generate_rsa_link = browser.first("textarea[name='#{private_key_field_name}'] + a")
        unless generate_rsa_link
          puts 'Unable to find the Generate RSA Certificate link for the given property.  If you are in a selector, please be sure to provide the two optional parameters to this method.'
        end
        generate_rsa_link.click

        browser.within '#rsa-certificate-form' do
          browser.fill_in 'rsa_certificate[domains]', with: wildcard_domain
          browser.click_on 'save-rsa-certificate-action'
        end
      end

      def set_boolean_property(checkbox_value)
        browser.check(checkbox_value)
      end

      def fill_in_selector_property(selector_input_reference:, selector_name:, selector_value:, sub_field_answers:)
        radio = browser.first(%Q(input[type="radio"][name="#{form_name}[#{selector_input_reference}][value]"][value="#{selector_value}"]))
        radio.click
        sub_field_answers.each do |label, value|
          selector_string = "#{form_name}[#{selector_input_reference}][#{selector_name}][#{label}]"

          if value[:attribute_name]
            selector_string += "[#{value[:attribute_name]}]"
          end

          browser.execute_script "$('a[data-masked-input-name=\"#{selector_string}\"]:contains(\"Change\")').click()"
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

      def open_form(form = nil)
        form = form || "show-#{form_name}-action"
        browser.visit '/'
        browser.click_on "show-#{product_name}-configure-action"
        browser.click_on form
      end

      private

      attr_reader :browser, :product_name, :form_name
    end
  end
end
