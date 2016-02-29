require 'net/https'
require 'date'

module OpsManagerUiDrivers
  module Version14
    class WebUi
      def initialize(browser:)
        @browser = browser
      end

      def setup_page
        Version14::Setup.new(browser: browser)
      end

      def product_dashboard
        Version14::ProductDashboard.new(browser: browser)
      end

      def state_change_progress
        Version14::StateChangeProgress.new(browser: browser)
      end

      def available_products
        Version14::AvailableProducts.new(browser: browser)
      end

      def ops_manager_director
        Version14::OpsManagerDirector.new(browser: browser)
      end

      def product_logs_for(product_name)
        Version14::ProductLogs.new(browser: browser, product_name: product_name)
      end

      def product_resources_configuration(product_name)
        Version14::ProductResourceConfiguration.new(browser: browser, product_name: product_name)
      end

      def product(product_name)
        Version14::ProductConfiguration.new(browser: browser, product_name: product_name)
      end

      def product_status_for(product_name)
        Version14::ProductStatusHelper.new(browser: browser, product_name: product_name)
      end

      def job_network_mapping_for(product_name)
        Version14::JobNetworkMappingHelper.new(browser: browser, product_name: product_name)
      end

      def product_availability_zones(product)
        Version14::ProductAvailabilityZones.new(browser: browser, product: product)
      end

      def assign_availability_zones_for_product(product:, zones:)
        if zones
          Version14::JobAvailabilityZoneMappingHelper.new(
            browser:      browser,
            product_name: product,
          ).assign_availability_zones!(
            singleton_availability_zone: zones[0]['name'],
            availability_zones:          zones.map { |z| z['name'] },
          )
        end
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
        browser.click_on 'show-microbosh-configure-action'
        browser.click_on 'show-director-availability-zone-assignment-action'

        availability_zone_options = browser.find_field('Singleton Availability Zone').all('option')
        availability_zone_options.each do |element|
          if element.text == az_name
            return element[:value]
          end
        end
      end

      private

      attr_reader :browser
    end
  end
end
