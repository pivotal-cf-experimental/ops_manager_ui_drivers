require 'ops_manager_ui_drivers/version17/settings'
using OpsManagerUiDrivers::BackportRefinements

module OpsManagerUiDrivers
  module Version18
    module Settings
      def self.for(test_settings)
        iaas_type = test_settings.dig('iaas_type')
        settings_class =
          [Vcloud, Vsphere, AWS, OpenStack, Google, Azure].find do |klass|
            klass.works_with?(iaas_type)
          end or fail("Unsupported IaaS: #{iaas_type.inspect}")
        settings_class.new(test_settings)
      end

      def self.build_browser_command(command, arg)
        {
          'browser_command' => command,
          'browser_arg' => arg,
        }
      end

      class Vcloud < Version17::Settings::Vcloud
      end

      class Vsphere < Version17::Settings::Vsphere
      end

      class AWS < Version17::Settings::AWS
      end

      class OpenStack < Version17::Settings::OpenStack
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
          }.merge(iaas_security_configuration_fields)
        end

        def advanced_infrastructure_config_fields
          {
          }
        end

        private

        def iaas_security_configuration_fields
          if @test_settings.dig('ops_manager', 'google', 'auth_json')
            {
              'access_type' => Settings.build_browser_command('choose', 'AuthJSON'),
              'auth_json' => @test_settings.dig('ops_manager', 'google', 'auth_json'),
            }
          else
            {
              'access_type' => Settings.build_browser_command('choose', 'Default Service Account'),
            }
          end
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
            'subscription_id' => @test_settings.dig('ops_manager', 'azure', 'subscription_id'),
            'tenant_id' => @test_settings.dig('ops_manager', 'azure', 'tenant_id'),
            'client_id' => @test_settings.dig('ops_manager', 'azure', 'client_id'),
            'client_secret' => @test_settings.dig('ops_manager', 'azure', 'client_secret'),
            'resource_group_name' => @test_settings.dig('ops_manager', 'azure', 'resource_group_name'),
            'bosh_storage_account_name' => @test_settings.dig('ops_manager', 'azure', 'bosh_storage_account_name'),
            'deployments_storage_account_name' => @test_settings.dig('ops_manager', 'azure', 'deployments_storage_account_name'),
            'default_security_group' => @test_settings.dig('ops_manager', 'azure', 'default_security_group'),
            'ssh_public_key' => @test_settings.dig('ops_manager', 'azure', 'ssh_public_key'),
            'ssh_private_key' => @test_settings.dig('ops_manager', 'azure', 'ssh_private_key'),
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
