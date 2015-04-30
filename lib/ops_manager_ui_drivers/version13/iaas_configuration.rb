module OpsManagerUiDrivers
  module Version13
    class IaasConfiguration
      def initialize(browser:, product:)
        @browser = browser
        @product = product
      end

      def configure_iaas
        open_form('iaas_configuration')

        yield

        save_form
      end

      def set_vsphere_credentials(vcenter_ip:, username:, password:)
        set_field('vcenter_ip', vcenter_ip)
        set_field('vcenter_username', username)
        set_field('vcenter_password', password)
      end

      def set_vcloud_credentials(vcd_url:, organization:, user:, password:)
        set_field('vcd_url', vcd_url)
        set_field('organization', organization)
        set_field('vcd_username', user)
        set_field('vcd_password', password)
      end


      def set_datacenter(datacenter)
        set_field('datacenter', datacenter)
      end

      def set_datastores(datastores)
        set_field('datastores_string', datastores)
      end

      def set_storage_profile(storage_profile)
        set_field('storage_profile', storage_profile)
      end

      private
      attr_reader(
        :browser,
        :product,
      )

      def save_form
        browser.click_on 'Save'
        browser.expect(browser.page).to browser.have_css('.flash-message.success')
      end

      def open_form(form)
        browser.visit '/'
        browser.click_on "show-#{product}-configure-action"
        browser.click_on "show-#{form}-action"
      end

      def set_field(field, value)
        browser.find_field("iaas_configuration[#{field}]").set(value)
      end
    end
  end
end
