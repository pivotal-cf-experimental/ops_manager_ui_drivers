require 'net/https'
require 'date'

module OpsManagerUiDrivers
  module Version13
    class WebUi
      def initialize(browser: nil)
        @browser = browser
      end

      def setup_page
        @setup_page ||= Version13::Setup.new(browser: browser)
      end

      def product_dashboard
        @product_dashboard ||= Version13::ProductDashboard.new(browser: browser)
      end

      def install_progress
        @install_progress ||= Version13::InstallProgress.new(browser: browser)
      end

      def available_products
        @available_products ||= Version13::AvailableProducts.new(browser: browser)
      end

      def product_logs_for(product_name)
        Version13::ProductLogs.new(browser: browser, product_name: product_name)
      end

      def current_time
        uri = URI(Capybara.app_host)
        uri.path = '/'
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https'), verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          response = http.request(Net::HTTP::Get.new(uri))
          DateTime.parse(response['Date'])
        end
      end

      def product_status_for(product_name)
        Version13::ProductStatusHelper.new(
          product_name: product_name,
          browser: browser,
        )
      end

      def job_network_mapping_for(product_name)
        Version13::JobNetworkMappingHelper.new(
          product_name: product_name,
          browser: browser,
        )
      end

      def assign_availability_zones_for_product(product:, zones:)
        if zones
          Version13::JobAvailabilityZoneMappingHelper.new(
            product_name: product,
            browser: browser,
          ).assign_availability_zones!(
            singleton_availability_zone: zones[0]['name'],
            availability_zones: zones.map { |z| z['name'] },
          )
        end
      end

      def ops_manager_director
        @ops_manager_director ||= Version13::OpsManagerDirector.new(browser: browser)
      end

      def product_availability_zones(product)
        @product_availability_zones ||= Version13::ProductAvailabilityZones.new(browser: browser, product: product)
      end

      def flash_message
        browser.find('.flash-message').text
      end

      def availability_zone_guid_for_name(az_name)
        browser.visit '/'
        browser.click_on 'show-microbosh-configure-action'
        browser.click_on 'show-director-availability-zone-assignment-action'

        availability_zone_options = browser.find_field('Singleton Availability Zone').all('option')
        availability_zone_options.each do |element|
          if element.text == az_name
            return element[:value]
          end
        end
      end

      def product_resources_configuration(product_name)
        Version13::ProductResourceConfiguration.new(browser: browser, product_name: product_name)
      end

      private

      attr_reader :browser

      def guid
        # jenkins gives us the job name in an environment variable, otherwise use the hostname
        job_name = ENV['JOB_NAME'] || `hostname`.chomp.split(/\./).first
        job_name.gsub(/[^[:alnum:]]+/, '_')
      end
    end
  end
end
