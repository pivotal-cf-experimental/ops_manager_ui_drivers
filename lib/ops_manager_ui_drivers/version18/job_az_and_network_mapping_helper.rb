require 'ops_manager_ui_drivers/version17/job_az_and_network_mapping_helper'

module OpsManagerUiDrivers
  module Version18
    class JobAzAndNetworkMappingHelper < Version17::JobAzAndNetworkMappingHelper
      SERVICE_NETWORK_FIELD_NAME = "product_service_network_reference"

      def assign_azs_and_network(singleton_availability_zone: nil, availability_zones: [], network:, service_network_name: nil)
        open_form

        got_azs = false
        browser.all(AVAILABILITY_ZONE_INPUT_SELECTOR).each do |checkbox|
          got_azs = true
          checkbox.set(false)
        end

        availability_zones.each { |az_name| browser.check("#{az_name}") } if got_azs

        browser.choose("#{singleton_availability_zone}") if got_azs

        browser.find_field(NETWORK_FIELD_NAME).find(:option, text: network).select_option

        if service_network_name
          browser.find_field(SERVICE_NETWORK_FIELD_NAME).find(:option, text: service_network_name).select_option
        end

        save_form
      end

      def assigned_service_network
        open_form
        selected_options = browser.find_field(SERVICE_NETWORK_FIELD_NAME).all('option[selected]')
        raise ArgumentError, "#{SERVICE_NETWORK_FIELD_NAME} not selected" if selected_options.empty?
        selected_options.first.text
      end
    end
  end
end
