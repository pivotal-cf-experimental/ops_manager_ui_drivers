require 'ops_manager_ui_drivers/version17/product_status_helper'

module OpsManagerUiDrivers
  module Version18
    class ProductStatusHelper < Version17::ProductStatusHelper
      def job_statuses(job_name_prefix)
        open_page

        wait_for_loading_indicator_to_disappear

        browser.within "##{product_name}-status" do
          job_rows = browser.all(:css, "tr[data-job-name ^= '#{job_name_prefix}']")

          job_rows.map { |job_row| Version18::JobStatusHelper.from_job_row(job_row) }
        end
      end

      def job_status(job_name_prefix)
        job_statuses(job_name_prefix).first
      end

      def job_status_in_az(_job_name)
        raise 'no longer supported in OM UI Drivers 1.8'
      end

      def resource_pool_for_job_in_az(_job_name, _az_guid, _vsphere_connection)
        raise 'no longer supported in OM UI Drivers 1.8'
      end

      def az_name_for_job_in_az(_job_name, _vpc_id, _az_guid)
        raise 'no longer supported in OM UI Drivers 1.8'
      end
    end
  end
end
