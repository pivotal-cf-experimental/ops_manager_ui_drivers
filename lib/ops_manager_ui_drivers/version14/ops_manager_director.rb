module OpsManagerUiDrivers
  module Version14
    class OpsManagerDirector
      def initialize(browser:)
        @browser = browser
      end

      def configure_microbosh(test_settings)
        configure_iaas(test_settings)

        config_director(test_settings.ops_manager)

        add_azs(test_settings.iaas_type, test_settings.ops_manager.availability_zones)

        assign_availability_zone(test_settings.iaas_type, test_settings.ops_manager.availability_zones)

        add_networks(test_settings)

        assign_networks(test_settings.ops_manager)
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
          when OpsManagerUiDrivers::AWS_IAAS_TYPE then
            configure_aws(
              aws_access_key: test_settings.ops_manager.aws.aws_access_key,
              aws_secret_key: test_settings.ops_manager.aws.aws_secret_key,
              vpc_id: test_settings.ops_manager.aws.vpc_id,
              security_group: test_settings.ops_manager.aws.security_group,
              key_pair_name: test_settings.ops_manager.aws.key_pair_name,
              ssh_private_key: test_settings.ops_manager.aws.ssh_key
            )
          when OpsManagerUiDrivers::OPENSTACK_IAAS_TYPE then
            configure_openstack(
              identity_endpoint: test_settings.ops_manager.openstack.identity_endpoint,
              username: test_settings.ops_manager.openstack.username,
              password: test_settings.ops_manager.openstack.password,
              tenant: test_settings.ops_manager.openstack.tenant,
              security_group_name: test_settings.ops_manager.openstack.security_group_name,
              key_pair_name: test_settings.ops_manager.openstack.key_pair_name,
              ssh_private_key: test_settings.ops_manager.openstack.ssh_private_key
            )
        end
      end

      def add_azs(iaas_type, iaas_availability_zones)
        case iaas_type
          when OpsManagerUiDrivers::AWS_IAAS_TYPE then
            return unless iaas_availability_zones
            availability_zones.add_aws_az(iaas_availability_zones.first['iaas_identifier'])
          else
            iaas_availability_zones && iaas_availability_zones.each do |az|
              availability_zones.add_az(az['name'], az['cluster'], az['resource_pool'])
            end
        end
      end

      def add_networks(test_settings)
        iaas_networks = test_settings.ops_manager.networks

        case test_settings.iaas_type
          when OpsManagerUiDrivers::AWS_IAAS_TYPE, OpsManagerUiDrivers::OPENSTACK_IAAS_TYPE then
            first_network = iaas_networks.first
            browser.click_on 'show-network-action'
            browser.fill_in 'network[networks][][name]', with: first_network['name']
            browser.fill_in 'network[networks][][iaas_network_identifier]', with: first_network['identifier']
            browser.fill_in 'network[networks][][subnet]', with: first_network['subnet']
            browser.fill_in 'network[networks][][reserved_ip_ranges]', with: first_network['reserved_ips']
            browser.fill_in 'network[networks][][dns]', with: first_network['dns']
            browser.fill_in 'network[networks][][gateway]', with: first_network['gateway']
            browser.click_on 'Save'
            flash_errors = browser.all('.flash-message.error ul.message li').to_a
            flash_errors.reject! { |node| node.text =~ /cannot reach gateway/i }

            if (flash_errors.length > 0)
              fail flash_errors.collect(&:text).inspect
            end
          else
            iaas_networks && iaas_networks.each do |network|
              networks.add_network(
                name: network['name'],
                iaas_network_identifier: network['identifier'],
                subnet: network['subnet'],
                reserved_ip_ranges: network['reserved_ips'],
                dns: network['dns'],
                gateway: network['gateway'],
              )
            end
        end
      end

      def config_director(ops_manager)
        browser.click_on 'Director Config'
        browser.fill_in('director_configuration[ntp_servers_string]', with: ops_manager.ntp_servers)
        browser.check('Enable VM Resurrector Plugin') if ops_manager.resurrector_enabled

        s3_blobstore = ops_manager.s3_blobstore
        if s3_blobstore
          browser.choose('Amazon S3')
          browser.fill_in('director_configuration[amazon_s3_blobstore_options][bucket_name]', with: s3_blobstore.bucket_name)
          browser.fill_in('director_configuration[amazon_s3_blobstore_options][access_key]', with: s3_blobstore.access_key_id)
          browser.fill_in('director_configuration[amazon_s3_blobstore_options][secret_key]', with: s3_blobstore.secret_access_key)
        end

        mysql = ops_manager.mysql
        if mysql
          browser.choose('External MySQL Database')
          browser.fill_in('director_configuration[external_database_options][host]', with: mysql.host)
          browser.fill_in('director_configuration[external_database_options][port]', with: mysql.port)
          browser.fill_in('director_configuration[external_database_options][user]', with: mysql.user)
          browser.fill_in('director_configuration[external_database_options][password]', with: mysql.password)
          browser.fill_in('director_configuration[external_database_options][database]', with: mysql.dbname)
        end

        browser.click_on 'Save'
      end

      def assign_availability_zone(iaas_type, iaas_availability_zones)
        return unless iaas_availability_zones
        case iaas_type
          when OpsManagerUiDrivers::AWS_IAAS_TYPE then
            browser.click_on 'Assign Availability Zones'
            browser.select(iaas_availability_zones.first['iaas_identifier'])
            browser.click_on 'Save'
          when OpsManagerUiDrivers::VSPHERE_IAAS_TYPE
            browser.click_on 'Assign Availability Zones'
            browser.select(iaas_availability_zones.first['name'])
            browser.click_on 'Save'
        end

      end

      def assign_networks(ops_manager)
        if ops_manager.vcenter
          deployment_network = ops_manager.networks[0]

          infrastructure_network =
            ops_manager.networks[1] ? ops_manager.networks[1] : ops_manager.networks[0]

          assign_networks_vsphere(
            deployment_network: deployment_network['name'],
            infrastructure_network: infrastructure_network['name'],
          )
        else
          assign_network(deployment_network: ops_manager.networks[0]['name'])
        end
      end

      def assign_networks_vsphere(infrastructure_network:, deployment_network:)
        browser.click_on 'Assign Networks'

        browser.within browser.find '#director_network_assignments_infrastructure_network' do
          browser.select infrastructure_network
        end

        browser.within browser.find '#director_network_assignments_deployment_network' do
          browser.select deployment_network
        end
        browser.click_on 'Save'
        browser.wait { browser.assert_text('Successfully assigned infrastructure network') }
      end

      def assign_network(deployment_network:)
        browser.click_on 'Assign Networks'

        browser.select(deployment_network, from: 'Network')
        browser.click_on 'Save'
      end

      private
      attr_reader :browser

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

      def configure_aws(aws_access_key:, aws_secret_key:, vpc_id:, security_group:, key_pair_name:, ssh_private_key:)
        iaas_configuration.configure_iaas do
          iaas_configuration.set_aws_credentials(
            access_key_id: aws_access_key,
            secret_access_key: aws_secret_key,
            vpc_id: vpc_id,
            security_group: security_group,
            key_pair_name: key_pair_name,
            ssh_private_key: ssh_private_key
          )
        end
      end

      def configure_openstack(
        identity_endpoint:,
          username:,
          password:,
          tenant:,
          security_group_name:,
          key_pair_name:,
          ssh_private_key:
      )
        iaas_configuration.configure_iaas do
          iaas_configuration.set_openstack_credentials(
            identity_endpoint: identity_endpoint,
            username: username,
            password: password,
            tenant: tenant,
            security_group_name: security_group_name,
            key_pair_name: key_pair_name,
            ssh_private_key: ssh_private_key
          )
        end
      end

      def iaas_configuration
        @iaas_configuration ||= Version14::IaasConfiguration.new(browser: browser, product: 'microbosh')
      end

      def availability_zones
        @availability_zones ||= Version14::AvailabilityZones.new(browser: browser, product: 'microbosh')
      end

      def networks
        @networks ||= Version14::Networks.new(browser: browser, product: 'microbosh')
      end
    end
  end
end
