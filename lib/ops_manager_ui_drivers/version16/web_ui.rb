require 'net/https'
require 'date'

module OpsManagerUiDrivers
  module Version16
    class WebUi
      def initialize(browser:)
        @browser = browser
      end

      def setup_page
        Version16::Setup.new(browser: browser)
      end

      def product_dashboard
        Version16::ProductDashboard.new(browser: browser)
      end

      def state_change_progress
        Version16::StateChangeProgress.new(browser: browser)
      end

      def available_products
        Version16::AvailableProducts.new(browser: browser)
      end

      def ops_manager_director
        Version16::OpsManagerDirector.new(browser: browser)
      end

      def product_logs_for(product_name)
        Version16::ProductLogs.new(browser: browser, product_name: product_name)
      end

      def product_resources_configuration(product_name)
        Version16::ProductResourceConfiguration.new(browser: browser, product_name: product_name)
      end

      def product(product_name)
        Version16::ProductConfiguration.new(browser: browser, product_name: product_name)
      end

      def product_status_for(product_name)
        Version16::ProductStatusHelper.new(browser: browser, product_name: product_name)
      end

      def job_network_mapping_for(product_name)
        Version16::JobNetworkMappingHelper.new(browser: browser, product_name: product_name)
      end

      def product_availability_zones(product_name)
        Version16::ProductAvailabilityZones.new(browser: browser, product: product_name)
      end

      def assign_availability_zones_for_product(product:, zones:)
        if zones
          Version16::JobAvailabilityZoneMappingHelper.new(
            browser:      browser,
            product_name: product,
          ).assign_availability_zones!(
            singleton_availability_zone: zones[0]['name'],
            availability_zones:          zones.map { |z| z['name'] },
          )
        end
      end

      def assign_azs_and_network_for_product(product_name:, zones:, network:)
        job_network_mapping_for(product_name).assign_product_to_network(network)
        assign_availability_zones_for_product(product: product_name, zones: zones)
      end

      def current_time
        uri      = URI(Capybara.app_host)
        uri.path = '/'
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https'), verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          response = http.request(Net::HTTP::Get.new(uri))
          DateTime.parse(response['Date'])
        end
      end

      def flash_message
        browser.find('.flash-message').text
      end

      def availability_zone_guid_for_name(az_name)
        browser.visit '/'
        browser.click_on 'show-p-bosh-configure-action'
        browser.click_on 'show-director-availability-zone-assignment-action'

        availability_zone_options = find_az_field
        availability_zone_options.each do |element|
          if element.text == az_name
            return element[:value]
          end
        end
      end

      private

      attr_reader :browser

      def guid
        # jenkins gives us the job name in an environment variable, otherwise use the hostname
        job_name = ENV['JOB_NAME'] || `hostname`.chomp.split(/\./).first
        job_name.gsub(/[^[:alnum:]]+/, '_')
      end

      def find_az_field
        browser.find_field('Singleton Availability Zone').all('option')
      rescue Capybara::ElementNotFound
        browser.find_field('Singleton Availability Zone', disabled: true).all('option')
      end
    end
  end
end
