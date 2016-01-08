module OpsManagerUiDrivers
  module Version15
    class ProductResourceConfiguration
      attr_reader :product_name

      def initialize(browser:, product_name:)
        @browser      = browser
        @product_name = product_name
      end

      def set_instances_for_job(job_name, instance_count)
        open_form
        browser.find_field("product_resources_form[#{job_name}][instances][value]").set(instance_count)
        save_form
      end

      def set_instance_type_for_job(job_name, instance_type)
        open_form
        browser.
          find("select[name='product_resources_form[#{job_name}][instance_type_id]']").
          find("option[value='#{instance_type}']").
          select_option
        save_form
      end

      def set_elb_names_for_job(job_name, comma_delimited_elb_names)
        open_form
        browser.find_field("product_resources_form[#{job_name}][elb_names]").set(comma_delimited_elb_names)
        save_form
      end

      def set_floating_ips_for_job(job_name, comma_delimited_floating_ips)
        open_form
        browser.find_field("product_resources_form[#{job_name}][floating_ips]").set(comma_delimited_floating_ips)
        save_form
      end

      def set_resources_for_jobs(resources_by_job, validate: true)
        open_form
        resources_by_job.each do |job, resources|
          resources.each do |resource_or_instance, value|
            browser.fill_in("product_resources_form[#{job}][#{resource_or_instance}][value]", with: value)
          end
        end
        save_form(validate: validate)
      end

      private

      attr_reader :browser

      def open_form
        browser.visit '/'
        browser.click_on "show-#{product_name}-configure-action"
        browser.click_on "show-#{product_name}-resource-sizes-action"
      end

      def save_form(validate: true)
        browser.click_on 'Save'

        fail('unexpected failure') unless browser.has_css?('.flash-message')

        if validate
          fail(browser.find('.flash-message.error').text) unless browser.has_css?('.flash-message.success')
        end
      end
    end
  end
end
