module OpsManagerUiDrivers
  module Version17
    class ProductStatusHelper
      def initialize(product_name:, browser:)
        @product_name = product_name
        @browser      = browser
      end

      def job_status(job_name)
        open_page

        wait_for_loading_indicator_to_disappear

        browser.within "##{product_name}-status" do
          job_row = browser.find(:css, "tr[data-ip-name ^= '#{job_name}']")

          Version17::JobStatusHelper.from_job_row(job_row)
        end
      end

      def job_status_in_az(job_name, az_guid)
        open_page

        wait_for_loading_indicator_to_disappear

        browser.within "##{product_name}-#{az_guid}-status-table" do
          job_row = browser.find(:css, "tr[data-ip-name ^= '#{job_name}']")

          Version17::JobStatusHelper.from_job_row(job_row)
        end
      end

      def resource_pool_for_job_in_az(job_name, az_guid, vsphere_connection)
        job_status = job_status_in_az("#{job_name}-partition-#{az_guid}", az_guid)

        job_ip = job_status.ips.fetch(0)

        vm = vsphere_connection.searchIndex.FindByIp(ip: job_ip, vmSearch: true)
        vm.resourcePool.name
      end

      def az_name_for_job_in_az(job_name, vpc_id, az_guid)
        job_status = job_status_in_az("#{job_name}-partition-#{az_guid}", az_guid)

        job_ip = job_status.ips.fetch(0)

        ec2 = ::AWS::EC2.new  # creds initialized in TestSettings::Renderer::SettingsFetcher::AWSSettings.initialize

        found_instance = ec2.instances.find do |instance|
          instance.private_ip_address == job_ip && instance.vpc_id == vpc_id && instance.status == :running
        end

        found_instance.availability_zone if found_instance
      end

      private

      attr_reader :browser, :product_name

      def open_page
        browser.visit '/'

        browser.click_on "show-#{product_name}-configure-action"
        browser.click_on 'show-status-action'
      end

      def wait_for_loading_indicator_to_disappear
        Capybara.using_wait_time 20 do
          browser.all('.status-loading', count: 0) # blocks until there are no spinners
        end
      end
    end
  end
end
