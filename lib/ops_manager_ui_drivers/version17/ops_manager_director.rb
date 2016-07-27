using OpsManagerUiDrivers::BackportRefinements

module OpsManagerUiDrivers
  module Version17
    class OpsManagerDirector
      def initialize(browser:, iaas_configuration: Version17::BoshProductSections::IaasConfiguration.new(browser: browser))
        @browser = browser
        @iaas_configuration = iaas_configuration
      end

      delegate :configure_icmp_checks, to: :networks

      def configure_bosh_product(test_settings)
        configure_iaas(test_settings)

        config_director(test_settings.dig('ops_manager'))

        add_availability_zones(test_settings.dig('iaas_type'), test_settings.dig('ops_manager', 'availability_zones'))

        add_networks(test_settings)

        assign_azs_and_networks(test_settings.dig('iaas_type'), test_settings.dig('ops_manager', 'availability_zones'), test_settings.dig('ops_manager'))

        configure_trusted_certificates(test_settings.dig('ops_manager', 'trusted_certificates'))
      end

      def configure_iaas(test_settings)
        iaas_settings = Settings.for(test_settings)
        iaas_specific_fields = iaas_settings.iaas_configuration_fields
        advanced_infrastructure_config_fields = iaas_settings.advanced_infrastructure_config_fields
        iaas_configuration.fill_iaas_settings(iaas_specific_fields)
        advanced_infrastructure_config.fill_advanced_infrastructure_config_settings(advanced_infrastructure_config_fields)
      end

      def add_availability_zones(iaas_type, iaas_availability_zones)
        case iaas_type
          when OpsManagerUiDrivers::AWS_IAAS_TYPE, OpsManagerUiDrivers::OPENSTACK_IAAS_TYPE, OpsManagerUiDrivers::GOOGLE_IAAS_TYPE
            return unless iaas_availability_zones
            iaas_availability_zones && iaas_availability_zones.uniq.each do |az|
              availability_zones.add_az('iaas_identifier' => az['iaas_identifier'])
            end
          when OpsManagerUiDrivers::VSPHERE_IAAS_TYPE
            iaas_availability_zones && iaas_availability_zones.uniq.each do |az|
              availability_zones.add_az('name' => az['name'], 'cluster' => az['cluster'], 'resource_pool' => az['resource_pool'])
            end
        end
      end

      def add_networks(test_settings)
        iaas_networks = test_settings.dig('ops_manager', 'networks')

        iaas_networks && iaas_networks.each do |network|
          networks.add_network(
            name: network['name'],
            subnets: network['subnets'],
          )
        end
      end

      def delete_network(network_name)
        networks.delete_network(network_name)
      end

      def config_director(ops_manager)
        browser.click_on 'Director Config'
        browser.fill_in('director_configuration[ntp_servers_string]', with: ops_manager.dig('ntp_servers'))
        browser.check('Enable VM Resurrector Plugin') if ops_manager.dig('resurrector_enabled')

        s3_blobstore = ops_manager.dig('s3_blobstore')
        if s3_blobstore
          browser.choose('S3 Compatible Blobstore')
          browser.fill_in('director_configuration[s3_blobstore_options][endpoint]', with: s3_blobstore.dig('endpoint'))
          browser.fill_in('director_configuration[s3_blobstore_options][bucket_name]', with: s3_blobstore.dig('bucket_name'))
          browser.fill_in('director_configuration[s3_blobstore_options][access_key]', with: s3_blobstore.dig('access_key_id'))
          @browser.execute_script "$('a[data-masked-input-name=\"director_configuration[s3_blobstore_options][secret_key]\"]:contains(\"Change\")').click()"
          browser.fill_in('director_configuration[s3_blobstore_options][secret_key]', with: s3_blobstore.dig('secret_access_key'))

          signature_version = s3_blobstore.dig('signature_version')
          if signature_version == 4
            browser.choose('V4 Signature')
            browser.fill_in('director_configuration[s3_blobstore_options][region]', with: s3_blobstore.dig('region'))
          end
        end

        mysql = ops_manager.dig('mysql')
        if mysql
          browser.choose('External MySQL Database')
          browser.fill_in('director_configuration[external_database_options][host]', with: mysql.dig('host'))
          browser.fill_in('director_configuration[external_database_options][port]', with: mysql.dig('port'))
          browser.fill_in('director_configuration[external_database_options][user]', with: mysql.dig('user'))
          @browser.execute_script "$('a[data-masked-input-name=\"director_configuration[external_database_options][password]\"]:contains(\"Change\")').click()"
          browser.fill_in('director_configuration[external_database_options][password]', with: mysql.dig('password'))
          browser.fill_in('director_configuration[external_database_options][database]', with: mysql.dig('dbname'))
        end

        browser.click_on 'Save'
      end

      def assign_azs_and_networks(iaas_type, iaas_availability_zones, ops_manager)
        case iaas_type
          when OpsManagerUiDrivers::AWS_IAAS_TYPE, OpsManagerUiDrivers::OPENSTACK_IAAS_TYPE
            browser.click_on 'Assign AZs and Networks'
            browser.select(ops_manager.dig('networks', 0, 'name'), from: 'Network')
            browser.select(iaas_availability_zones.first['iaas_identifier'], from: 'Singleton Availability Zone')
          when OpsManagerUiDrivers::VSPHERE_IAAS_TYPE
            browser.click_on 'Assign AZs and Networks'
            browser.select(ops_manager.dig('networks', 0, 'name'), from: 'Network')
            browser.select(iaas_availability_zones.first['name'], from: 'Singleton Availability Zone')
          when OpsManagerUiDrivers::VCLOUD_IAAS_TYPE
            browser.click_on 'Assign Networks'
            browser.select(ops_manager.dig('networks', 0, 'name'), from: 'Network')
        end
        browser.click_on 'Save'
      end

      def assign_network(iaas_type:, network_name:)
        case iaas_type
          when OpsManagerUiDrivers::AWS_IAAS_TYPE, OpsManagerUiDrivers::OPENSTACK_IAAS_TYPE, OpsManagerUiDrivers::VSPHERE_IAAS_TYPE
            browser.click_on 'Assign AZs and Networks'
            browser.select(network_name, from: 'Network')
          when OpsManagerUiDrivers::VCLOUD_IAAS_TYPE
            browser.click_on 'Assign Networks'
            browser.select(network_name, from: 'Network')
        end
        browser.click_on 'Save'
      end

      def configure_vm_passwords(use_generated_passwords: true)
        browser.click_on 'Security'
        if use_generated_passwords
          browser.choose('Generate passwords')
        else
          browser.choose('Use default BOSH password')
        end
        browser.click_on 'Save'
        browser.poll_up_to_times(20) { browser.assert_text('Settings updated') }
      end

      def configure_trusted_certificates(trusted_certificates)
        return unless trusted_certificates
        browser.click_on 'Security'
        browser.fill_in('security_tokens[trusted_certificates]', with: trusted_certificates)
        browser.click_on 'Save'
      end

      def selected_network_name(iaas_type)
        case iaas_type
          when OpsManagerUiDrivers::VCLOUD_IAAS_TYPE
            browser.click_on 'Assign Networks'
          else
            browser.click_on 'Assign AZs and Networks'
        end
        selected_options = browser.find_field('Network').all('option[selected]')
        selected_options.first.text unless selected_options.empty?
      end

      def selected_singleton_az_name(iaas_type)
        case iaas_type
          when OpsManagerUiDrivers::VCLOUD_IAAS_TYPE
            browser.click_on 'Assign Networks'
          else
            browser.click_on 'Assign AZs and Networks'
        end
        selected_options = browser.find_field('bosh_product[singleton_availability_zone_reference]').all('option[selected]')
        selected_options.first.text unless selected_options.empty?
      end

      def configure_security_group(test_settings) # lost in upgrade from 1.6 => 1.7
        iaas_configuration.fill_iaas_settings(
          'security_group' => test_settings.dig('ops_manager', 'aws', 'security_group_id'),
        )
      end

      private

      attr_reader :browser, :iaas_configuration


      def availability_zones
        @availability_zones ||= Version17::BoshProductSections::AvailabilityZones.new(browser: browser)
      end

      def networks
        @networks ||= Version17::BoshProductSections::Networks.new(browser: browser)
      end

      def advanced_infrastructure_config
        @advanced_infrastructure_config ||= Version17::BoshProductSections::AdvancedInfrastructureConfig.new(browser: browser)
      end
    end
  end
end
