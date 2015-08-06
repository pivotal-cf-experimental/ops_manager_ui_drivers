module OpsManagerUiDrivers
  module Version16
    class AvailabilityZones
      def initialize(browser:)
        @browser = browser
      end

      def add_single_az(iaas_identifier)
        open_form

        set_fields('iaas_identifier' => iaas_identifier)

        save_form
      end

      def add_az(fields)
        open_form

        browser.click_on 'Add'
        set_fields(fields)
        save_form
      end

      private

      attr_reader :browser

      def save_form
        browser.click_on 'Save'
        browser.expect(browser.page).to browser.have_css('.flash-message.success')
      end

      def open_form
        browser.visit '/'
        browser.click_on 'show-microbosh-configure-action'
        browser.click_on 'show-availability_zones-action'
      end

      def set_fields(fields)
        fields.each do |field, value|
          set_field(field, value)
        end
      end

      def set_field(field, value)
        last_field(field).set(value)
      end

      def last_field(field)
        browser.all(:field, "availability_zones[availability_zones][][#{field}]").last
      end
    end
  end
end
