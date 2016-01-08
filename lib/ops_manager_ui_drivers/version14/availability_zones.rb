module OpsManagerUiDrivers
  module Version14
    class AvailabilityZones
      def initialize(browser:, product:)
        @browser = browser
        @product = product
      end

      def add_aws_az(iaas_identifier)
        open_form('availability_zones')

        set_fields(fields: {'iaas_identifier' => iaas_identifier})
        save_form
      end

      def add_az(name, cluster, resource_pool)
        open_form('availability_zones')

        browser.click_on 'Add'
        set_fields(
          fields: {
            'name'          => name,
            'cluster'       => cluster,
            'resource_pool' => resource_pool,
          }
        )
        save_form
      end

      private
      attr_reader :browser, :product

      def save_form
        browser.click_on 'Save'
        browser.expect(browser.page).to browser.have_css('.flash-message.success')
      end

      def open_form(form)
        browser.visit '/'
        browser.click_on "show-#{product}-configure-action"
        browser.click_on "show-#{form}-action"
      end

      def set_fields(fields:)
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
