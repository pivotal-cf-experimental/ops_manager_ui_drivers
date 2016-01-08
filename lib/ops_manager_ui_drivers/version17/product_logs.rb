require 'date'

module OpsManagerUiDrivers
  module Version17
    class ProductLogs
      def initialize(browser:, product_name:)
        @browser      = browser
        @product_name = product_name
      end

      def request_job_logs(job_name)
        browser.visit('/')
        browser.click_on("show-#{product_name}-configure-action")
        browser.click_on('show-status-action')
        browser.find(%Q(a[id^="download-#{job_name}-"][id$="-0-log-action"])).click
      end

      def most_recent_log_creation_time
        browser.visit('/')
        browser.click_on("show-#{product_name}-configure-action")
        browser.click_on('show-logs-action')

        log_row = browser.all('#downloaded_logs tr').
          select { |e| e.find(%Q(a[href^="/products/#{product_name}"])) }.
          last

        return unless log_row

        date_string = log_row.all('td').last.text
        DateTime.parse(date_string)
      end

      private

      attr_reader :product_name, :browser
    end
  end
end
