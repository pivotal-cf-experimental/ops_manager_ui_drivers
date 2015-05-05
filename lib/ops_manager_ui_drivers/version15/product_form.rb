module OpsManagerUiDrivers
  module Version15
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
        browser.click_on 'Generate Self-Signed RSA Certificate'
        browser.within '#rsa-certificate-form' do
          browser.fill_in 'rsa_certificate[domains]', with: wildcard_domain
          browser.click_on 'save-rsa-certificate-action'
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
