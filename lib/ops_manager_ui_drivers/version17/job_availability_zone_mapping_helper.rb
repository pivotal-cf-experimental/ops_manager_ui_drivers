module OpsManagerUiDrivers
  module Version17
    class JobAvailabilityZoneMappingHelper
      def initialize(product_name: nil, browser: nil)
        @product_name = product_name
        @browser = browser
      end

      SINGLETON_AVAILABILITY_ZONE_INPUT_SELECTOR = "input[name='product[singleton_availability_zone_reference]']"
      AVAILABILITY_ZONE_INPUT_SELECTOR = "input[name='product[availability_zone_references][]']"

      def assign_availability_zones!(singleton_availability_zone:, availability_zones:)
        open_form

        browser.all(AVAILABILITY_ZONE_INPUT_SELECTOR).each do |checkbox|
          checkbox.set(false)
        end

        availability_zones.each do |az_name|
          browser.check("#{az_name}")
        end

        browser.choose("#{singleton_availability_zone}")

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

      private

      attr_reader :browser, :product_name

      def open_form
        browser.visit '/'
        browser.click_on "show-#{product_name}-configure-action"
        browser.click_on "show-#{product_name}-availability-zone-assignment-action"
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
