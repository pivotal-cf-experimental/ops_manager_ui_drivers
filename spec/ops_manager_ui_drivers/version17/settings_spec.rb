require 'spec_helper'

module OpsManagerUiDrivers
  module Version17
    RSpec.describe Settings do
      describe 'Openstack settings' do
        let(:settings_hash) do
          {
            'iaas_type'   => 'openstack',
            'ops_manager' => {
              'openstack' => {
                'identity_endpoint'   => 'IdentityEndpoint',
                'username'            => 'Username',
                'password'            => 'Password',
                'tenant'              => 'Tenant',
                'security_group_name' => 'SecurityGroupName',
                'region'              => 'Region',
                'key_pair_name'       => 'KeyPairName',
                'ssh_private_key'     => 'SshPrivateKey',
                'disable_dhcp'        => false,
                'connection_options'  => 'ConnectionOptions',
              }
            }
          }
        end

        subject(:openstack_settings) { Settings.for(settings_hash) }

        it 'should have the correct iaas_configuration fields' do
          iaas_configuration_fields = openstack_settings.iaas_configuration_fields
          expect(iaas_configuration_fields['identity_endpoint']).to eq('IdentityEndpoint')
          expect(iaas_configuration_fields['username']).to eq('Username')
          expect(iaas_configuration_fields['password']).to eq('Password')
          expect(iaas_configuration_fields['tenant']).to eq('Tenant')
          expect(iaas_configuration_fields['security_group']).to eq('SecurityGroupName')
          expect(iaas_configuration_fields['region']).to eq('Region')
          expect(iaas_configuration_fields['key_pair_name']).to eq('KeyPairName')
          expect(iaas_configuration_fields['ssh_private_key']).to eq('SshPrivateKey')
          expect(iaas_configuration_fields['disable_dhcp']).to eq(false)
        end

        it 'should have the correct advanced_infrastructure_config fields' do
          iaas_configuration_fields = openstack_settings.advanced_infrastructure_config_fields
          expect(iaas_configuration_fields['connection_options']).to eq('ConnectionOptions')
        end
      end

      describe 'AWS settings' do
        let(:settings_hash) do
          {
            'iaas_type'   => 'aws',
            'ops_manager' => {
              'aws' => {
                'aws_access_key' => 'AwsAccessKey',
                'aws_secret_key' => 'AwsSecretKey',
                'vpc_id'         => 'VpcId',
                'security_group_id' => 'SecurityGroup',
                'key_pair_name'  => 'KeyPairName',
                'ssh_key'        => 'SSHKey',
                'region'         => 'Region',
                'encrypt_disk'   => false,
              }
            }
          }
        end

        subject(:aws_settings) { Settings.for(settings_hash) }

        it 'should have the correct iaas_configuration fields' do
          iaas_configuration_fields = aws_settings.iaas_configuration_fields
          expect(iaas_configuration_fields['access_key_id']).to eq('AwsAccessKey')
          expect(iaas_configuration_fields['secret_access_key']).to eq('AwsSecretKey')
          expect(iaas_configuration_fields['vpc_id']).to eq('VpcId')
          expect(iaas_configuration_fields['security_group']).to eq('SecurityGroup')
          expect(iaas_configuration_fields['key_pair_name']).to eq('KeyPairName')
          expect(iaas_configuration_fields['ssh_private_key']).to eq('SSHKey')
          expect(iaas_configuration_fields['region']).to eq('Region')
          expect(iaas_configuration_fields['encrypted']).to eq(false)
        end

        it 'should have the correct advanced_infrastructure_config fields' do
          iaas_configuration_fields = aws_settings.advanced_infrastructure_config_fields
          expect(iaas_configuration_fields).to eq({})
        end
      end

      describe 'vSphere settings' do
        let(:settings_hash) do
          {
            'iaas_type'   => 'vsphere',
            'ops_manager' => {
              'vcenter' => {
                'creds'                => {
                  'ip'       => 'CredsIp',
                  'username' => 'Username',
                  'password' => 'Password'
                },
                'datacenter'           => 'Datacenter',
                'ephemeral_datastore'  => 'Ephemeral Datastore',
                'persistent_datastore' => 'Persistent Datastore',
                'bosh_vm_folder'       => 'BoshVmFolder',
                'bosh_template_folder' => 'BoshTemplateFolder',
                'bosh_disk_path'       => 'BoshDiskPath',
              }
            }
          }
        end

        subject(:vsphere_settings) { Settings.for(settings_hash) }

        it 'should have the correct iaas_configuration fields' do
          iaas_configuration_fields = vsphere_settings.iaas_configuration_fields
          expect(iaas_configuration_fields['vcenter_ip']).to eq('CredsIp')
          expect(iaas_configuration_fields['vcenter_username']).to eq('Username')
          expect(iaas_configuration_fields['vcenter_password']).to eq('Password')
          expect(iaas_configuration_fields['datacenter']).to eq('Datacenter')
          expect(iaas_configuration_fields['ephemeral_datastores_string']).to eq('Ephemeral Datastore')
          expect(iaas_configuration_fields['persistent_datastores_string']).to eq('Persistent Datastore')
          expect(iaas_configuration_fields['bosh_vm_folder']).to eq('BoshVmFolder')
          expect(iaas_configuration_fields['bosh_template_folder']).to eq('BoshTemplateFolder')
        end

        it 'should have the correct advanced_infrastructure_config fields' do
          iaas_configuration_fields = vsphere_settings.advanced_infrastructure_config_fields
          expect(iaas_configuration_fields).to eq({})
        end
      end

      describe 'vCloud settings' do
        let(:settings_hash) do
          {
            'iaas_type'   => 'vcloud',
            'ops_manager' => {
              'vcloud' => {
                'creds' => {
                  'url'          => 'CredsURL',
                  'organization' => 'CredsOrganization',
                  'user'         => 'Username',
                  'password'     => 'Password'
                },
                'vdc'   => {
                  'name'            => 'VdcName',
                  'storage_profile' => 'VdcStorageProfile',
                  'catalog_name'    => 'VdcCatalogName',
                },
              }
            }
          }
        end

        subject(:vcloud_settings) { Settings.for(settings_hash) }

        it 'should have the correct iaas_configuration fields' do
          iaas_configuration_fields = vcloud_settings.iaas_configuration_fields
          expect(iaas_configuration_fields['vcd_url']).to eq('CredsURL')
          expect(iaas_configuration_fields['organization']).to eq('CredsOrganization')
          expect(iaas_configuration_fields['vcd_username']).to eq('Username')
          expect(iaas_configuration_fields['vcd_password']).to eq('Password')
          expect(iaas_configuration_fields['datacenter']).to eq('VdcName')
          expect(iaas_configuration_fields['storage_profile']).to eq('VdcStorageProfile')
          expect(iaas_configuration_fields['catalog_name']).to eq('VdcCatalogName')
        end

        it 'should have the correct advanced_infrastructure_config fields' do
          iaas_configuration_fields = vcloud_settings.advanced_infrastructure_config_fields
          expect(iaas_configuration_fields).to eq({})
        end
      end
    end
  end
end
