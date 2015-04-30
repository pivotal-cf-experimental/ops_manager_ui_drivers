require 'date'

module OpsManagerUiDrivers
  module Version13
    class ProductLogs
      def initialize(browser:, product_name:)
        @browser = browser
        @product_name = product_name
      end

      def request_job_logs(job_name)
        visit_product_status_page
        browser.find(%Q(a[id^="download-#{job_name}-"][id$="-0-log-action"])).click
      end

      def most_recent_log_creation_time
        visit_product_logs_page

        most_recent_logs_timestamp
      end

      private

      attr_reader :product_name, :browser

      def visit_product_configure_page
        browser.visit('/')
        browser.click_on("show-#{product_name}-configure-action")
      end

      def visit_product_status_page
        visit_product_configure_page
        browser.click_on('show-status-action')
      end

      def visit_product_logs_page
        visit_product_configure_page
        browser.click_on('show-logs-action')
      end

      def most_recent_logs
        browser.all('#downloaded_logs tr').select { |e| e.find(%Q(a[href^="/products/#{product_name}"])) }.last
      end

      def most_recent_logs_timestamp
        return unless (log_row = most_recent_logs)

        date_string = log_row.all('td').last.text
        DateTime.parse(date_string)
      end
    end
  end
end
