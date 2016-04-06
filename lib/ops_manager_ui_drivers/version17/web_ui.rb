require 'net/https'
require 'date'

module OpsManagerUiDrivers
  module Version17
    class WebUi
      def initialize(browser:)
        @browser = browser
      end

      def setup_page
        Version17::Setup.new(browser: browser)
      end

      def settings_page
        Version17::UserSettings.new(browser: browser)
      end

      def product_dashboard
        Version17::ProductDashboard.new(browser: browser)
      end

      def state_change_progress
        Version17::StateChangeProgress.new(browser: browser)
      end

      def available_products
        Version17::AvailableProducts.new(browser: browser)
      end

      def ops_manager_director
        Version17::OpsManagerDirector.new(browser: browser)
      end

      def product_logs_for(product_name)
        Version17::ProductLogs.new(browser: browser, product_name: product_name)
      end

      def product_resources_configuration(product_name)
        Version17::ProductResourceConfiguration.new(browser: browser, product_name: product_name)
      end

      def product(product_name)
        Version17::ProductConfiguration.new(browser: browser, product_name: product_name)
      end

      def product_status_for(product_name)
        Version17::ProductStatusHelper.new(browser: browser, product_name: product_name)
      end

      def product_availability_zones(product_name)
        Version17::ProductAvailabilityZones.new(browser: browser, product_name: product_name)
      end

      def job_azs_and_network_mapping_for(product_name)
        Version17::JobAzAndNetworkMappingHelper.new(
          browser: browser,
          product_name: product_name,
        )
      end

      def assign_azs_and_network_for_product(product_name:, zones:, network:)
        zones_present = zones && zones.first

        singleton_az = zones_present ? (zones[0]['iaas_identifier'] || zones[0]['name']) : nil
        availability_zones = zones_present ? zones.map { |zone| (zone['iaas_identifier'] || zone['name']) } : nil

        job_azs_and_network_mapping_for(product_name).assign_azs_and_network(
          singleton_availability_zone: singleton_az,
          availability_zones: availability_zones,
          network: network,
        )
      end

      def current_time
        uri = URI(Capybara.app_host)
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
        browser.click_on 'show-director-az-and-network-assignment-action'

        availability_zone_options = find_az_field
        availability_zone_options.each do |element|
          if element.text == az_name
            return element[:value]
          end
        end
      end

      private

      attr_reader :browser

      def find_az_field
        browser.find_field('Singleton Availability Zone').all('option')
      rescue Capybara::ElementNotFound
        browser.find_field('Singleton Availability Zone', disabled: true).all('option')
      end
    end
  end
end
