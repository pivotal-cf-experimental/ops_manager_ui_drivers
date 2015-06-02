module OpsManagerUiDrivers
  module Version15
    module Settings
      class Vcloud
        def initialize(test_settings)
          @test_settings = test_settings
        end

        def configure(iaas_configuration)
          iaas_configuration.set_field('vcd_url', test_settings.ops_manager.vcloud.creds.url)
          iaas_configuration.set_field('organization', test_settings.ops_manager.vcloud.creds.organization)
          iaas_configuration.set_field('vcd_username', test_settings.ops_manager.vcloud.creds.user)
          iaas_configuration.set_field('vcd_password', test_settings.ops_manager.vcloud.creds.password)
          iaas_configuration.set_field('datacenter', test_settings.ops_manager.vcloud.vdc.name)
          iaas_configuration.set_field('storage_profile', test_settings.ops_manager.vcloud.vdc.storage_profile)
          iaas_configuration.set_field('catalog_name', test_settings.ops_manager.vcloud.vdc.catalog_name)
        end

        private

        attr_reader :test_settings
      end

      class Vsphere
        def initialize(test_settings)
          @test_settings = test_settings
        end

        def configure(iaas_configuration)
          iaas_configuration.set_field('vcenter_ip', test_settings.ops_manager.vcenter.creds.ip)
          iaas_configuration.set_field('vcenter_username', test_settings.ops_manager.vcenter.creds.username)
          iaas_configuration.set_field('vcenter_password', test_settings.ops_manager.vcenter.creds.password)
          iaas_configuration.set_field('datacenter', test_settings.ops_manager.vcenter.datacenter)
          iaas_configuration.set_field('datastores_string', test_settings.ops_manager.vcenter.datastore)
          iaas_configuration.set_field('microbosh_vm_folder', test_settings.ops_manager.vcenter.microbosh_vm_folder)
          iaas_configuration.set_field('microbosh_template_folder', test_settings.ops_manager.vcenter.microbosh_template_folder)
          iaas_configuration.set_field('microbosh_disk_path', test_settings.ops_manager.vcenter.microbosh_disk_path)
        end

        private

        attr_reader :test_settings
      end

      class AWS
        def initialize(test_settings)
          @test_settings = test_settings
        end

        def configure(iaas_configuration)
          iaas_configuration.set_field('access_key_id', test_settings.ops_manager.aws.aws_access_key)
          iaas_configuration.set_field('secret_access_key', test_settings.ops_manager.aws.aws_secret_key)
          iaas_configuration.set_field('vpc_id', test_settings.ops_manager.aws.vpc_id)
          iaas_configuration.set_field('security_group', test_settings.ops_manager.aws.security_group)
          iaas_configuration.set_field('key_pair_name', test_settings.ops_manager.aws.key_pair_name)
          iaas_configuration.set_field('ssh_private_key', test_settings.ops_manager.aws.ssh_key)
        end

        private

        attr_reader :test_settings
      end

      class OpenStack
        def initialize(test_settings)
          @test_settings = test_settings
        end

        def configure(iaas_configuration)
          iaas_configuration.set_field('identity_endpoint', test_settings.ops_manager.openstack.identity_endpoint)
          iaas_configuration.set_field('username', test_settings.ops_manager.openstack.username)
          iaas_configuration.set_field('password', test_settings.ops_manager.openstack.password)
          iaas_configuration.set_field('tenant', test_settings.ops_manager.openstack.tenant)
          iaas_configuration.set_field('security_group', test_settings.ops_manager.openstack.security_group_name)
          iaas_configuration.set_field('key_pair_name', test_settings.ops_manager.openstack.key_pair_name)
          iaas_configuration.set_field('ssh_private_key', test_settings.ops_manager.openstack.ssh_private_key)
        end

        private

        attr_reader :test_settings
      end
    end
  end
end
