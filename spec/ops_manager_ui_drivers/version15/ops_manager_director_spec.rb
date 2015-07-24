require 'spec_helper'
require 'capybara'
require 'capybara/rspec/matchers'
require 'recursive-open-struct'

module OpsManagerUiDrivers
  module Version15
    describe OpsManagerDirector do
      class FakeCapybaraExampleGroup < RSpec::Core::ExampleGroup
        include Capybara::DSL
        include Capybara::RSpecMatchers
        include OpsManagerUiDrivers::WaitHelper
      end

      let(:browser) do
        instance_double(FakeCapybaraExampleGroup)
      end

      let(:iaas_configuration) do
        Version15::IaasConfiguration.new(browser: browser).tap do |iaas_configuration|
          allow(iaas_configuration).to receive(:set_field)
        end
      end

      let(:test_settings_hash) do
        {}
      end

      let(:test_settings) do
        RecursiveOpenStruct.new(test_settings_hash)
      end

      subject(:ops_manager_director) do
        OpsManagerDirector.new(browser: browser, iaas_configuration: iaas_configuration)
      end

      before do
        allow(browser).to receive(:visit)
        allow(browser).to receive(:click_on)
        allow(browser).to receive(:fill_in)
        allow(browser).to receive(:select)
        allow(browser).to receive(:choose)
        allow(browser).to receive(:wait).and_yield
        allow(browser).to receive(:page)
        allow(browser).to receive(:expect).and_return(instance_double(RSpec::Expectations::ExpectationTarget, to: nil))
        allow(browser).to receive(:have_css)
        allow(browser).to receive(:has_text?)
      end

      describe '#configure_iaas' do
        it 'navigates to and submits the "iaas_configuration" form' do
          settings = double('Fake IaaS Settings', fields: {})
          allow(Settings).to receive(:for).and_return(settings)

          ops_manager_director.configure_iaas(test_settings)

          expect(browser).to have_received(:visit).with('/')
          expect(browser).to have_received(:click_on).with('show-microbosh-configure-action')
          expect(browser).to have_received(:click_on).with('show-iaas_configuration-action')
          expect(browser).to have_received(:click_on).with('Save')
        end

        context 'when the IaaS is Vcloud' do
          before do
            test_settings_hash['iaas_type']   = 'vcloud'
            test_settings_hash['ops_manager'] = {
              'vcloud' => {
                'creds' => {
                  'url'          => 'fake-vclouds-creds-url',
                  'organization' => 'fake-vclouds-creds-organization',
                  'user'         => 'fake-vclouds-creds-user',
                  'password'     => 'fake-vclouds-creds-password',
                },
                'vdc'   => {
                  'name'            => 'fake-vdc-name',
                  'storage_profile' => 'fake-vdc-storage_profile',
                  'catalog_name'    => 'fake-vdc-catalog_name',
                }
              }
            }

            ops_manager_director.configure_iaas(test_settings)
          end

          it 'configures the vcloud creds for bosh to manage vms' do
            expect(iaas_configuration).to have_received(:set_field).with('vcd_url', 'fake-vclouds-creds-url')
            expect(iaas_configuration).to have_received(:set_field).with('organization', 'fake-vclouds-creds-organization')
            expect(iaas_configuration).to have_received(:set_field).with('vcd_username', 'fake-vclouds-creds-user')
            expect(iaas_configuration).to have_received(:set_field).with('vcd_password', 'fake-vclouds-creds-password')
          end

          it 'configures the vdc name, storage profile and catalog name' do
            expect(iaas_configuration).to have_received(:set_field).with('datacenter', 'fake-vdc-name')
            expect(iaas_configuration).to have_received(:set_field).with('storage_profile', 'fake-vdc-storage_profile')
            expect(iaas_configuration).to have_received(:set_field).with('catalog_name', 'fake-vdc-catalog_name')
          end
        end

        context 'when the IaaS is Vsphere' do
          before do
            test_settings_hash['iaas_type']   = 'vsphere'
            test_settings_hash['ops_manager'] = {
              'vcenter' => {
                'creds'                     => {
                  'ip'       => 'fake-vcenter-creds-ip',
                  'username' => 'fake-vcenter-creds-username',
                  'password' => 'fake-vcenter-creds-password',
                },
                'datacenter'                => 'fake-vcenter-datacenter',
                'datastore'                 => 'fake-vcenter-datastores',
                'microbosh_vm_folder'       => 'fake-vcenter-microbosh_vm_folder',
                'microbosh_template_folder' => 'fake-vcenter-microbosh_template_folder',
                'microbosh_disk_path'       => 'fake-vcenter-microbosh_disk_path',
              }
            }

            ops_manager_director.configure_iaas(test_settings)
          end

          it 'configures the vcenter creds for bosh to manage vms' do
            expect(iaas_configuration).to have_received(:set_field).with('vcenter_ip', 'fake-vcenter-creds-ip')
            expect(iaas_configuration).to have_received(:set_field).with('vcenter_username', 'fake-vcenter-creds-username')
            expect(iaas_configuration).to have_received(:set_field).with('vcenter_password', 'fake-vcenter-creds-password')
          end

          it 'sets the vcenter datacenter and datastore for bosh managed vms' do
            expect(iaas_configuration).to have_received(:set_field).with('datacenter', 'fake-vcenter-datacenter')
            expect(iaas_configuration).to have_received(:set_field).with('datastores_string', 'fake-vcenter-datastores')
          end

          it 'sets the microbosh vm & template folders' do
            expect(iaas_configuration).to have_received(:set_field).with('microbosh_vm_folder', 'fake-vcenter-microbosh_vm_folder')
            expect(iaas_configuration).to have_received(:set_field).with('microbosh_template_folder', 'fake-vcenter-microbosh_template_folder')
          end

          it 'sets the microbosh disk path' do
            expect(iaas_configuration).to have_received(:set_field).with('microbosh_disk_path', 'fake-vcenter-microbosh_disk_path')
          end
        end

        context 'when the IaaS is AWS' do
          before do
            test_settings_hash['iaas_type']   = 'aws'
            test_settings_hash['ops_manager'] = {
              'aws' => {
                'aws_access_key' => 'fake-aws-aws_access_key',
                'aws_secret_key' => 'fake-aws-aws_secret_key',
                'vpc_id'         => 'fake-aws-vpc_id',
                'security_group' => 'fake-aws-security_group',
                'key_pair_name'  => 'fake-aws-key_pair_name',
                'ssh_key'        => 'fake-aws-ssh_key',
                'region'         => 'fake-region',
              }
            }

            ops_manager_director.configure_iaas(test_settings)
          end

          it 'configures the aws credentials for bosh to manage vms' do
            expect(iaas_configuration).to have_received(:set_field).with('access_key_id', 'fake-aws-aws_access_key')
            expect(iaas_configuration).to have_received(:set_field).with('secret_access_key', 'fake-aws-aws_secret_key')
          end

          it 'sets the aws security group for bosh managed vms' do
            expect(iaas_configuration).to have_received(:set_field).with('security_group', 'fake-aws-security_group')
          end

          it 'sets the aws vpc for bosh managed vms' do
            expect(iaas_configuration).to have_received(:set_field).with('vpc_id', 'fake-aws-vpc_id')
          end

          it 'sets the aws ssh key pair and private key for bosh managed vms' do
            expect(iaas_configuration).to have_received(:set_field).with('key_pair_name', 'fake-aws-key_pair_name')
            expect(iaas_configuration).to have_received(:set_field).with('ssh_private_key', 'fake-aws-ssh_key')
          end

          it 'sets the configured region' do
            expect(iaas_configuration).to have_received(:set_field).with('region', 'fake-region')
          end
        end

        context 'when the IaaS is OpenStack' do
          before do
            test_settings_hash['iaas_type']   = 'openstack'
            test_settings_hash['ops_manager'] = {
              'openstack' => {
                'identity_endpoint'   => 'fake-openstack-identity_endpoint',
                'username'            => 'fake-openstack-username',
                'password'            => 'fake-openstack-password',
                'tenant'              => 'fake-openstack-tenant',
                'security_group_name' => 'fake-openstack-security_group_name',
                'key_pair_name'       => 'fake-openstack-key_pair_name',
                'ssh_private_key'     => 'fake-openstack-ssh_private_key',
              }
            }

            ops_manager_director.configure_iaas(test_settings)
          end

          it 'configures the openstack credentials for bosh to manage vms' do
            expect(iaas_configuration).to have_received(:set_field).with('identity_endpoint', 'fake-openstack-identity_endpoint')
            expect(iaas_configuration).to have_received(:set_field).with('username', 'fake-openstack-username')
            expect(iaas_configuration).to have_received(:set_field).with('password', 'fake-openstack-password')
          end

          it 'sets the openstack tenant for bosh managed vms' do
            expect(iaas_configuration).to have_received(:set_field).with('tenant', 'fake-openstack-tenant')
          end

          it 'sets the openstack security group for bosh managed vms' do
            expect(iaas_configuration).to have_received(:set_field).with('security_group', 'fake-openstack-security_group_name')
          end

          it 'sets the openstack ssh key pair & private key for bosh managed vms' do
            expect(iaas_configuration).to have_received(:set_field).with('key_pair_name', 'fake-openstack-key_pair_name')
            expect(iaas_configuration).to have_received(:set_field).with('ssh_private_key', 'fake-openstack-ssh_private_key')
          end
        end
      end

      describe '#add_availability_zones' do
        context 'when the infrastructure is AWS' do
          it 'navigates to and submits the availability zone form' do
            iaas_identifier_field = double(:iaas_identifier_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][iaas_identifier]').and_return([iaas_identifier_field])

            ops_manager_director.add_availability_zones(OpsManagerUiDrivers::AWS_IAAS_TYPE, [{'iaas_identifier' => 'aws_az'}])

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-microbosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-availability_zones-action').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][iaas_identifier]').ordered
            expect(iaas_identifier_field).to have_received(:set).with('aws_az').ordered
            expect(browser).to have_received(:click_on).with('Save').ordered
          end
        end

        context 'when the infrastructure is OpenStack' do
          it 'navigates to and submits the availability zone form' do
            iaas_identifier_field = double(:iaas_identifier_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][iaas_identifier]').and_return([iaas_identifier_field])
            
            ops_manager_director.add_availability_zones(OpsManagerUiDrivers::OPENSTACK_IAAS_TYPE, [{'iaas_identifier' => 'openstack_az'}])

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-microbosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-availability_zones-action').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][iaas_identifier]').ordered
            expect(iaas_identifier_field).to have_received(:set).with('openstack_az').ordered
            expect(browser).to have_received(:click_on).with('Save').ordered
          end
        end

        context 'when the infrastructure is anything else' do
          it 'navigates to and submits the availability zone form' do
            name_field = double(:name_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][name]').and_return([name_field])
            cluster_field = double(:cluster_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][cluster]').and_return([cluster_field])
            resource_pool_field = double(:resource_pool_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][resource_pool]').and_return([resource_pool_field])

            vsphere_options = {'name' => 'vsphere_az', 'cluster' => 'vsphere_cluster', 'resource_pool' => 'vsphere_resource_pool'}
            ops_manager_director.add_availability_zones(OpsManagerUiDrivers::VSPHERE_IAAS_TYPE, [vsphere_options])

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-microbosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-availability_zones-action').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][name]').ordered
            expect(name_field).to have_received(:set).with('vsphere_az').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][cluster]').ordered
            expect(cluster_field).to have_received(:set).with('vsphere_cluster').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][resource_pool]').ordered
            expect(resource_pool_field).to have_received(:set).with('vsphere_resource_pool').ordered
            expect(browser).to have_received(:click_on).with('Save').ordered
          end
        end
      end

      describe '#assign_availability_zone' do
        context 'when the infrastructure is AWS' do
          it 'assigns an availability zone' do
            ops_manager_director.assign_availability_zone('aws', [{'iaas_identifier' => 'fake-iaas_identifier'}])

            expect(browser).to have_received(:click_on).with('Assign Availability Zones')
            expect(browser).to have_received(:select).with('fake-iaas_identifier')
            expect(browser).to have_received(:click_on).with('Save')
          end
        end

        context 'when the infrastructure is OpenStack' do
          it 'assigns an availability zone' do
            ops_manager_director.assign_availability_zone('openstack', [{'iaas_identifier' => 'fake-iaas_identifier'}])

            expect(browser).to have_received(:click_on).with('Assign Availability Zones')
            expect(browser).to have_received(:select).with('fake-iaas_identifier')
            expect(browser).to have_received(:click_on).with('Save')
          end
        end

        context 'when the infrastructure is vSphere' do
          it 'assigns an availability zone' do
            ops_manager_director.assign_availability_zone('vsphere', [{'name' => 'fake-name'}])

            expect(browser).to have_received(:click_on).with('Assign Availability Zones')
            expect(browser).to have_received(:select).with('fake-name')
            expect(browser).to have_received(:click_on).with('Save')
          end
        end
      end

      describe '#configure_vm_passwords' do
        it 'navigates to and submits the vm_passwords form' do
          ops_manager_director.configure_vm_passwords

          expect(browser).to have_received(:click_on).with('Security').ordered
          expect(browser).to have_received(:choose).with('Generate passwords').ordered
          expect(browser).to have_received(:click_on).with('Save').ordered
          expect(browser).to have_received(:wait).ordered
          expect(browser).to have_received(:has_text?).with('Settings updated').ordered
        end

        context 'when the users specifies whether to use generated passwords' do
          before { ops_manager_director.configure_vm_passwords(use_generated_passwords: use_generated_passwords) }

          context 'when the user chooses to generate vm passwords' do
            let(:use_generated_passwords) { true }

            it 'navigates to and submits the vm_passwords form' do
              expect(browser).to have_received(:click_on).with('Security')
              expect(browser).to have_received(:choose).with('Generate passwords')
              expect(browser).to have_received(:click_on).with('Save')
            end
          end

          context 'when the user chooses to use the bosh default password' do
            let(:use_generated_passwords) { false }

            it 'navigates to and submits the vm_passwords form' do
              expect(browser).to have_received(:click_on).with('Security')
              expect(browser).to have_received(:choose).with('Use default BOSH password')
              expect(browser).to have_received(:click_on).with('Save')
            end
          end
        end
      end

      describe '#customize_resource_config' do
        context 'when a microbosh persistent disk size is configured' do
          let(:test_settings_hash) do
            {
              'ops_manager' => {
                'resource_config' => {
                  'persistent_disk' => 10240,
                }
              }
            }
          end

          it 'decreases the persistent disk size to 10gb to minimize our usage' do
            ops_manager_director.customize_resource_config(test_settings.ops_manager.resource_config)

            expect(browser).to have_received(:click_on).with('Resource Config')
            expect(browser).to have_received(:fill_in).with('product_resources_form[director][persistent_disk][value]', with: 10240)
          end
        end

        context 'when a microbosh persistent disk size is not configured' do
          let(:test_settings_hash) do
            {
              'ops_manager' => {}
            }
          end

          it 'uses the default the persistent disk size to 10gb to minimize our usage' do
            ops_manager_director.customize_resource_config(test_settings.ops_manager.resource_config)

            expect(browser).not_to have_received(:fill_in).with('product_resources_form[director][persistent_disk][value]', anything)
          end
        end
      end
    end
  end
end
