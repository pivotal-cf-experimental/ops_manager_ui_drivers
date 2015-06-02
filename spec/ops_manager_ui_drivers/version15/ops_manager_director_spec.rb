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
      end

      let(:browser) do
        instance_double(FakeCapybaraExampleGroup)
      end

      let(:iaas_configuration) do
        Version15::IaasConfiguration.new(browser: browser).tap do |iaas_configuration|
          allow(iaas_configuration).to receive(:set_field)
        end
      end

      subject(:ops_manager_director) do
        OpsManagerDirector.new(browser: browser, iaas_configuration: iaas_configuration)
      end

      before do
        allow(browser).to receive(:visit)
        allow(browser).to receive(:click_on)
        allow(browser).to receive(:page)
        allow(browser).to receive(:expect).and_return(instance_double(RSpec::Expectations::ExpectationTarget, to: nil))
        allow(browser).to receive(:have_css)
      end

      describe '#configure_iaas' do
        let(:test_settings_hash) do
          {}
        end

        let(:test_settings) do
          RecursiveOpenStruct.new(test_settings_hash)
        end

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
    end
  end
end
