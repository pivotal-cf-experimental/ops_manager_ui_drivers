require 'spec_helper'
require 'recursive-open-struct'

module OpsManagerUiDrivers
  module Version15
    RSpec.describe Settings do
      describe 'Openstack settings' do
        let(:settings_hash) { {
          iaas_type:   'openstack',
          ops_manager: {
            openstack: {
              identity_endpoint: 'IdentityEndpoint',
              username: 'Username',
              password: 'Password',
              tenant: 'Tenant',
              security_group_name: 'SecurityGroupName',
              region: 'Region',
              key_pair_name: 'KeyPairName',
              ssh_private_key: 'SshPrivateKey',
              disable_dhcp: false,
            }
          }
        } }
        let(:test_settings) { RecursiveOpenStruct.new(settings_hash, recurse_over_arrays: true) }

        subject(:openstack_settings) { Settings.for(test_settings) }

        it 'should have the correct fields' do
          fields = subject.fields
          expect(fields['identity_endpoint']).to eq('IdentityEndpoint')
          expect(fields['username']).to eq('Username')
          expect(fields['password']).to eq('Password')
          expect(fields['tenant']).to eq('Tenant')
          expect(fields['security_group']).to eq('SecurityGroupName')
          expect(fields['region']).to eq('Region')
          expect(fields['key_pair_name']).to eq('KeyPairName')
          expect(fields['ssh_private_key']).to eq('SshPrivateKey')
          expect(fields['disable_dhcp']).to eq(false)
        end
      end
    end
  end
end
