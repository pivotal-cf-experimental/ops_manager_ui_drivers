module OpsManagerUiDrivers
  module Version13
    class ProductResourceConfiguration
      attr_reader :product_name

      def initialize(browser:, product_name:)
        @browser = browser
        @product_name = product_name
      end

      def set_instances_for_job(job_name, instance_count)
        open_form
        browser.find_field("product_resources_form[#{job_name}][instances][value]").set(instance_count)
        save_form
      end

      def set_elb_for_job(job_name, elb_name)
        open_form
        browser.find_field("product_resources_form[#{job_name}][elb_name]").set(elb_name)
        save_form
      end

      private

      attr_reader :browser

      def open_form
        browser.visit '/'
        browser.click_on "show-#{product_name}-configure-action"
        browser.click_on "show-#{product_name}-resource-sizes-action"
      end

      def save_form
        browser.click_on 'Save'

        unless browser.has_css?('.flash-message.success')
          if browser.has_css?('.flash-message.error')
            raise browser.find('.flash-message.error').text
          else
            raise 'unexpected failure'
          end
        end
      end
    end
  end
end
