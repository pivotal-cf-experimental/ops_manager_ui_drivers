module OpsManagerUiDrivers
  module Version16
    class ProductConfiguration
      attr_reader :product_name

      def initialize(browser:, product_name:)
        @browser = browser
        @product_name = product_name
      end

      def upload_stemcell(stemcell_file_path)
        visit_product_page
        browser.click_on "show-#{product_name}-stemcell-assignment-action"
        browser.attach_file('product_stemcell[file]', stemcell_file_path, {visible: false})
        browser.wait {
          browser.has_text?("Stemcell '#{File.basename(stemcell_file_path)}' has been uploaded successfully.")
        }
      end

      def product_form(form_name)
        Version16::ProductForm.new(browser: browser, product_name: product_name, form_name: form_name)
      end

      private

      attr_reader :browser, :product_name

      def visit_product_page
        browser.visit '/'
        browser.click_on "show-#{product_name}-configure-action"
      end
    end
  end
end
