using OpsManagerUiDrivers::BackportRefinements

module OpsManagerUiDrivers
  module Version17
    module Settings
      def self.for(test_settings)
        iaas_type = test_settings.dig('iaas_type')
        settings_class =
          [Vcloud, Vsphere, AWS, OpenStack].find do |klass|
            klass.works_with?(iaas_type)
          end or fail("Unsupported IaaS: #{iaas_type.inspect}")
        settings_class.new(test_settings)
      end

      class Vcloud
        def self.works_with?(iaas_type)
          iaas_type == 'vcloud'
        end

        def initialize(test_settings)
          @test_settings = test_settings
        end

        def iaas_configuration_fields
          {
            'vcd_url'         => @test_settings.dig('ops_manager', 'vcloud', 'creds', 'url'),
            'organization'    => @test_settings.dig('ops_manager', 'vcloud', 'creds', 'organization'),
            'vcd_username'    => @test_settings.dig('ops_manager', 'vcloud', 'creds', 'user'),
            'vcd_password'    => @test_settings.dig('ops_manager', 'vcloud', 'creds', 'password'),
            'datacenter'      => @test_settings.dig('ops_manager', 'vcloud', 'vdc', 'name'),
            'storage_profile' => @test_settings.dig('ops_manager', 'vcloud', 'vdc', 'storage_profile'),
            'catalog_name'    => @test_settings.dig('ops_manager', 'vcloud', 'vdc', 'catalog_name'),
          }
        end

        def advanced_infrastructure_config_fields
          {}
        end
      end

      class Vsphere
        def self.works_with?(iaas_type)
          iaas_type == 'vsphere'
        end

        def initialize(test_settings)
          @test_settings = test_settings
        end

        def iaas_configuration_fields
          {
            'vcenter_host'                 => vcenter_host(@test_settings),
            'vcenter_username'             => @test_settings.dig('ops_manager', 'vcenter', 'creds', 'username'),
            'vcenter_password'             => @test_settings.dig('ops_manager', 'vcenter', 'creds', 'password'),
            'datacenter'                   => @test_settings.dig('ops_manager', 'vcenter', 'datacenter'),
            'ephemeral_datastores_string'  => @test_settings.dig('ops_manager', 'vcenter', 'ephemeral_datastore'),
            'persistent_datastores_string' => @test_settings.dig('ops_manager', 'vcenter', 'persistent_datastore'),
            'bosh_vm_folder'               => @test_settings.dig('ops_manager', 'vcenter', 'bosh_vm_folder'),
            'bosh_template_folder'         => @test_settings.dig('ops_manager', 'vcenter', 'bosh_template_folder'),
            'bosh_disk_path'               => @test_settings.dig('ops_manager', 'vcenter', 'bosh_disk_path'),
          }
        end

        def advanced_infrastructure_config_fields
          {}
        end

        private

        def vcenter_host(test_settings)
          test_settings.dig('ops_manager', 'vcenter', 'creds', 'host') ||
            test_settings.dig('ops_manager', 'vcenter', 'creds', 'ip')
        end
      end

      class AWS
        def self.works_with?(iaas_type)
          iaas_type == 'aws'
        end

        def initialize(test_settings)
          @test_settings = test_settings
        end

        def iaas_configuration_fields
          iaas_security_configuration_fields.merge(
            'vpc_id'            => @test_settings.dig('ops_manager', 'aws', 'vpc_id'),
            'security_group'    => @test_settings.dig('ops_manager', 'aws', 'security_group_id'),
            'key_pair_name'     => @test_settings.dig('ops_manager', 'aws', 'key_pair_name'),
            'ssh_private_key'   => @test_settings.dig('ops_manager', 'aws', 'ssh_key'),
            'region'            => @test_settings.dig('ops_manager', 'aws', 'region'),
            'encrypted'         => @test_settings.dig('ops_manager', 'aws', 'encrypt_disk'),
          )
        end

        def advanced_infrastructure_config_fields
          {}
        end

        private

        def build_browser_command(command, arg)
          {
            'browser_command' => command,
            'browser_arg' => arg,
          }
        end

        def iaas_security_configuration_fields
          if @test_settings.dig('ops_manager', 'aws', 'instance_profile')
            {
              'access_type' => build_browser_command('choose', 'Use AWS Instance Profile'),
              'iam_instance_profile' => @test_settings.dig('ops_manager', 'aws', 'instance_profile'),
            }
          else
            {
              'access_key_id' => @test_settings.dig('ops_manager', 'aws', 'aws_access_key'),
              'secret_access_key' => @test_settings.dig('ops_manager', 'aws', 'aws_secret_key'),
            }
          end
        end
      end

      class OpenStack
        def self.works_with?(iaas_type)
          iaas_type == 'openstack'
        end

        def initialize(test_settings)
          @test_settings = test_settings
        end

        def iaas_configuration_fields
          {
            'identity_endpoint' => @test_settings.dig('ops_manager', 'openstack', 'identity_endpoint'),
            'username'          => @test_settings.dig('ops_manager', 'openstack', 'username'),
            'password'          => @test_settings.dig('ops_manager', 'openstack', 'password'),
            'tenant'            => @test_settings.dig('ops_manager', 'openstack', 'tenant'),
            'security_group'    => @test_settings.dig('ops_manager', 'openstack', 'security_group_name'),
            'key_pair_name'     => @test_settings.dig('ops_manager', 'openstack', 'key_pair_name'),
            'ssh_private_key'   => @test_settings.dig('ops_manager', 'openstack', 'ssh_private_key'),
            'api_ssl_cert'      => @test_settings.dig('ops_manager', 'openstack', 'api_ssl_cert'),
            'region'            => @test_settings.dig('ops_manager', 'openstack', 'region'),
            'disable_dhcp'      => @test_settings.dig('ops_manager', 'openstack', 'disable_dhcp'),
          }
        end

        def advanced_infrastructure_config_fields
          {
            'connection_options' => @test_settings.dig('ops_manager', 'openstack', 'connection_options')
          }
        end
      end

      class Google
        def self.works_with?(iaas_type)
          iaas_type == 'google'
        end

        def initialize(test_settings)
          @test_settings = test_settings
        end

        def iaas_configuration_fields
          {
            'project' => @test_settings.dig('ops_manager', 'google', 'project'),
            'region' => @test_settings.dig('ops_manager', 'google', 'region'),
            'ssh_private_key' => @test_settings.dig('ops_manager', 'google', 'ssh_private_key'),
          }
        end

        def advanced_infrastructure_config_fields
          {
          }
        end
      end

      class Azure
        def self.works_with?(iaas_type)
          iaas_type == 'azure'
        end

        def initialize(test_settings)
          @test_settings = test_settings
        end

        def iaas_configuration_fields
          {
          }
        end

        def advanced_infrastructure_config_fields
          {
          }
        end
      end
    end
  end
end
