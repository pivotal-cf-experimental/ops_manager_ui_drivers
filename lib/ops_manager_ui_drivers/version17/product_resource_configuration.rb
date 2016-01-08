module OpsManagerUiDrivers
  module Version17
    class ProductResourceConfiguration
      attr_reader :product_name

      def initialize(browser:, product_name:)
        @browser      = browser
        @product_name = product_name
      end

      def set_instances_for_job(job_name, instance_count, validate: true)
        set_resources_for_jobs(job_name, :instances, instance_count, validate: validate)
      end

      def set_ephemeral_disk_for_job(job_name, ephemeral_disk, validate: true)
        set_resources_for_jobs(job_name, :ephemeral_disk, ephemeral_disk, validate: validate)
      end

      def set_instance_type_for_job(job_name, instance_type, validate: true)
        open_form
        browser.
          find("select[name='product_resources_form[#{job_name}][instance_type_id]']").
          find("option[value='#{instance_type}']").
          select_option
        save_form(validate: validate)
      end

      def set_disk_type_for_job(job_name, disk_type_id, validate: true)
        open_form
        browser.
          find("select[name='product_resources_form[#{job_name}][disk_type_id]']").
          find("option[value='#{disk_type_id}']").
          select_option
        save_form(validate: validate)
      end

      def set_elb_names_for_job(job_name, comma_delimited_elb_names, validate: true)
        open_form
        browser.find_field("product_resources_form[#{job_name}][elb_names]").set(comma_delimited_elb_names)
        save_form(validate: validate)
      end

      def set_floating_ips_for_job(job_name, comma_delimited_floating_ips, validate: true)
        open_form
        browser.find_field("product_resources_form[#{job_name}][floating_ips]").set(comma_delimited_floating_ips)
        save_form(validate: validate)
      end

      private

      attr_reader :browser

      def set_resources_for_jobs(job_name, resource, value, validate: true)
        open_form
        browser.fill_in("product_resources_form[#{job_name}][#{resource}][value]", with: value)
        save_form(validate: validate)
      end

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
