module OpsManagerUiDrivers
  module Version13
    class OpsManagerDirector
      def initialize(browser:)
        @browser = browser
      end

      def configure_microbosh(test_settings)
        @product = test_settings.persistent_ops_manager.v13.microbosh_product_name

        configure_iaas(test_settings)

        config_director(ntp_servers: test_settings.ops_manager.ntp_servers)

        add_azs(test_settings.ops_manager.availability_zones)

        assign_availability_zone(test_settings.ops_manager.availability_zones)

        add_networks(test_settings.ops_manager.networks)

        assign_networks(test_settings.ops_manager)
      end

      private
      attr_reader :browser

      def product
        @product || 'microbosh'
      end

      def configure_iaas(test_settings)
        case test_settings.iaas_type
          when OpsManagerUiDrivers::VCLOUD_IAAS_TYPE then
            configure_vcloud(
              vcd_url: test_settings.ops_manager.vcloud.creds.url,
              organization: test_settings.ops_manager.vcloud.creds.organization,
              user: test_settings.ops_manager.vcloud.creds.user,
              password: test_settings.ops_manager.vcloud.creds.password,
              datacenter: test_settings.ops_manager.vcloud.vdc.name,
              storage_profile: test_settings.ops_manager.vcloud.vdc.storage_profile,
            )
          when OpsManagerUiDrivers::VSPHERE_IAAS_TYPE then
            configure_vcenter(
              ip: test_settings.ops_manager.vcenter.creds.ip,
              username: test_settings.ops_manager.vcenter.creds.username,
              password: test_settings.ops_manager.vcenter.creds.password,
              datacenter: test_settings.ops_manager.vcenter.datacenter,
              datastores: test_settings.ops_manager.vcenter.datastore,
            )
        end
      end

      def add_azs(iaas_availability_zones)
        iaas_availability_zones && iaas_availability_zones.each do |az|
          availability_zones.add_az(az['name'], az['cluster'], az['resource_pool'])
        end
      end

      def add_networks(iaas_networks)
        iaas_networks && iaas_networks.each do |network|
          networks.add_network(
            name: network['name'],
            iaas_network_identifier: network['identifier'],
            subnet: network['subnet'],
            dns: network['dns'],
            gateway: network['gateway'],
            reserved_ip_ranges: network['reserved_ips'],
          )
        end
      end

      def config_director(ntp_servers:)
        browser.click_on 'Director Config'
        browser.fill_in('director_configuration[ntp_servers_string]', with: ntp_servers)
        browser.click_on 'Save'
      end

      def assign_availability_zone(iaas_availability_zones)
        if iaas_availability_zones
          browser.click_on 'Assign Availability Zones'
          browser.select(iaas_availability_zones.first['name'])
          browser.click_on 'Save'
        end
      end

      def assign_networks(ops_manager)
        deployment_network = ops_manager.networks[0]

        infrastructure_network =
          ops_manager.networks[1] ? ops_manager.networks[1] : ops_manager.networks[0]

        assign_networks_on_browser(
          infrastructure_network: infrastructure_network['name'],
          deployment_network: deployment_network['name'],
        )
      end

      def assign_networks_on_browser(infrastructure_network:, deployment_network:)
        browser.click_on 'Assign Networks'

        browser.within browser.find '#director_network_assignments_infrastructure_network' do
          browser.select infrastructure_network
        end

        browser.within browser.find '#director_network_assignments_deployment_network' do
          browser.select deployment_network
        end
        browser.click_on 'Save'
      end

      def configure_vcenter(ip:, username:, password:, datacenter:, datastores:)
        iaas_configuration.configure_iaas do
          iaas_configuration.set_vsphere_credentials(vcenter_ip: ip, username: username, password: password)
          iaas_configuration.set_datacenter(datacenter)
          iaas_configuration.set_datastores(datastores)
        end
      end

      def configure_vcloud(vcd_url:, organization:, user:, password:, datacenter:, storage_profile:)
        iaas_configuration.configure_iaas do
          iaas_configuration.set_vcloud_credentials(vcd_url: vcd_url, organization: organization, user: user, password: password)
          iaas_configuration.set_datacenter(datacenter)
          iaas_configuration.set_storage_profile(storage_profile)
        end
      end

      def iaas_configuration
        @iaas_configuration ||= Version13::IaasConfiguration.new(browser: browser, product: product)
      end

      def availability_zones
        @availability_zones ||= Version13::AvailabilityZones.new(browser: browser, product: product)
      end

      def networks
        @networks ||= Version13::Networks.new(browser: browser, product: product)
      end
    end
  end
end
