module OpsManagerUiDrivers
  module Version16
    class WebUi
      class ProductAvailabilityZones
        def initialize(browser:, product_name:)
          @browser      = browser
          @product_name = product_name
        end

        def assign_availability_zones(singleton_availability_zone:, availability_zones:)
          open_form
          browser.choose(singleton_availability_zone)
          # we don't change the assignments in clean install yet,
          # otherwise we'd want to clear them out first
          availability_zones.each do |az_name|
            browser.check(az_name)
          end
          save_form
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

          browser.expect(browser.page).to browser.have_css('.flash-message.success')
        end
      end
    end
  end
end
