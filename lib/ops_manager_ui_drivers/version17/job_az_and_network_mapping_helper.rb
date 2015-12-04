module OpsManagerUiDrivers
  module Version17
    class JobAzAndNetworkMappingHelper
      def initialize(product_name:, browser:)
        @product_name = product_name
        @browser = browser
      end

      SINGLETON_AVAILABILITY_ZONE_INPUT_SELECTOR = "input[name='product[singleton_availability_zone_reference]']"
      AVAILABILITY_ZONE_INPUT_SELECTOR = "input[name='product[availability_zone_references][]']"
      NETWORK_FIELD_NAME = "product_network_reference"

      def assign_azs_and_network(singleton_availability_zone: nil, availability_zones: [], network:)
        open_form

        got_azs = false
        browser.all(AVAILABILITY_ZONE_INPUT_SELECTOR).each do |checkbox|
          got_azs = true
          checkbox.set(false)
        end

        availability_zones.each { |az_name| browser.check("#{az_name}") } if got_azs

        browser.choose("#{singleton_availability_zone}") if got_azs

        browser.find_field(NETWORK_FIELD_NAME).find(:option, text: network).select_option

        save_form
      end

      def singleton_availability_zone
        open_form

        selected_options = browser.all("#{SINGLETON_AVAILABILITY_ZONE_INPUT_SELECTOR}[selected='selected']").map do |radio|
          browser.find("label[for='#{radio[:id]}']").text
        end

        raise ArgumentError, 'availability_zone not selected' if selected_options.empty?
        selected_options.first
      end

      def availability_zones
        open_form

        browser.all("#{AVAILABILITY_ZONE_INPUT_SELECTOR}[checked='checked']").map do |checkbox|
          browser.find("label[for='#{checkbox[:id]}']").text
        end
      end

      def product_network
        open_form
        selected_options = browser.find_field(NETWORK_FIELD_NAME).all('option[selected]')
        raise ArgumentError, "#{NETWORK_FIELD_NAME} not selected" if selected_options.empty?
        selected_options.first.text
      end

      private

      attr_reader :browser, :product_name

      def open_form
        browser.visit '/'
        browser.click_on "show-#{product_name.dasherize}-configure-action"
        browser.click_on "show-#{product_name}-azs-and-network-assignment-action"
      end

      def save_form
        browser.click_on 'Save'

        unless browser.has_css?('.flash-message.success')
          if browser.has_css?('.flash-message.error')
            raise browser.find('.flash-message.error').text
          else
            raise 'unexpected failure'
          end
        end
      end
    end
  end
end
