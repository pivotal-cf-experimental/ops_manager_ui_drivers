require 'spec_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec/matchers'
using OpsManagerUiDrivers::BackportRefinements

module OpsManagerUiDrivers
  module Version18
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
        Version18::BoshProductSections::IaasConfiguration.new(browser: browser).tap do |iaas_configuration|
          allow(iaas_configuration).to receive(:set_field)
        end
      end
      let(:advanced_infrastructure_configuration) { Version18::BoshProductSections::AdvancedInfrastructureConfig.new(browser: browser) }

      let(:test_settings_hash) do
        {}
      end

      subject(:ops_manager_director) do
        OpsManagerUiDrivers::Version18::OpsManagerDirector.new(browser: browser, iaas_configuration: iaas_configuration)
      end

      before do
        allow(browser).to receive(:visit)
        allow(browser).to receive(:click_on)
        allow(browser).to receive(:fill_in)
        allow(browser).to receive(:select)
        allow(browser).to receive(:choose)
        allow(browser).to receive(:poll_up_to_times).and_yield
        allow(browser).to receive(:page)
        allow(browser).to receive(:expect).and_return(instance_double(RSpec::Expectations::ExpectationTarget, to: nil))
        allow(browser).to receive(:have_css)
        allow(browser).to receive(:has_css?).and_return(true)
        allow(browser).to receive(:assert_text)
        allow(browser).to receive(:execute_script)
        allow(iaas_configuration).to receive(:fill_iaas_settings)

        allow(Version18::BoshProductSections::AdvancedInfrastructureConfig).to receive(:new).and_return(advanced_infrastructure_configuration)
        allow(advanced_infrastructure_configuration).to receive(:fill_advanced_infrastructure_config_settings)
      end

      describe '#configure_iaas' do
        it 'navigates to and submits the "iaas_configuration" form' do
          settings = double('Fake IaaS Settings', iaas_configuration_fields: {}, advanced_infrastructure_config_fields: {})
          allow(OpsManagerUiDrivers::Version18::Settings).to receive(:for).and_return(settings)

          ops_manager_director.configure_iaas(test_settings_hash)

          expect(iaas_configuration).to have_received(:fill_iaas_settings)
        end

        context 'when the IaaS is Vcloud' do
          before do
            test_settings_hash['iaas_type'] = 'vcloud'
            test_settings_hash['ops_manager'] = {
              'vcloud' => {
                'creds' => {
                  'url' => 'fake-vclouds-creds-url',
                  'organization' => 'fake-vclouds-creds-organization',
                  'user' => 'fake-vclouds-creds-user',
                  'password' => 'fake-vclouds-creds-password',
                },
                'vdc' => {
                  'name' => 'fake-vdc-name',
                  'storage_profile' => 'fake-vdc-storage_profile',
                  'catalog_name' => 'fake-vdc-catalog_name',
                }
              }
            }

            ops_manager_director.configure_iaas(test_settings_hash)
          end

          it 'configures the vcloud creds for bosh to manage vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'vcd_url' => 'fake-vclouds-creds-url',
                'organization' => 'fake-vclouds-creds-organization',
                'vcd_username' => 'fake-vclouds-creds-user',
                'vcd_password' => 'fake-vclouds-creds-password',
              )
            )
          end

          it 'configures the vdc name, storage profile and catalog name' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'datacenter' => 'fake-vdc-name',
                'storage_profile' => 'fake-vdc-storage_profile',
                'catalog_name' => 'fake-vdc-catalog_name',
              )
            )
          end
        end

        context 'when the IaaS is Vsphere' do
          let(:vcenter_creds) do
            {
              'ip' => 'fake-vcenter-creds-ip',
              'username' => 'fake-vcenter-creds-username',
              'password' => 'fake-vcenter-creds-password',
            }
          end

          before do
            test_settings_hash['iaas_type'] = 'vsphere'
            test_settings_hash['ops_manager'] = {
              'vcenter' => {
                'creds' => vcenter_creds,
                'datacenter' => 'fake-vcenter-datacenter',
                'ephemeral_datastore' => 'e-fake-vcenter-datastores',
                'persistent_datastore' => 'p-fake-vcenter-datastores',
                'bosh_vm_folder' => 'fake-vcenter-bosh_vm_folder',
                'bosh_template_folder' => 'fake-vcenter-bosh_template_folder',
                'bosh_disk_path' => 'fake-vcenter-bosh_disk_path',
              }
            }

            ops_manager_director.configure_iaas(test_settings_hash)
          end

          it 'configures the vcenter creds for bosh to manage vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'vcenter_host' => 'fake-vcenter-creds-ip',
                'vcenter_username' => 'fake-vcenter-creds-username',
                'vcenter_password' => 'fake-vcenter-creds-password',
              )
            )
          end

          context 'when vcenter host is specified' do
            let(:vcenter_creds) do
              {
                'host' => 'fake-vcenter-creds-host',
                'username' => 'fake-vcenter-creds-username',
                'password' => 'fake-vcenter-creds-password',
              }
            end

            it 'configures the vcenter creds for bosh to manage vms' do
              expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
                hash_including(
                  'vcenter_host' => 'fake-vcenter-creds-host',
                  'vcenter_username' => 'fake-vcenter-creds-username',
                  'vcenter_password' => 'fake-vcenter-creds-password',
                )
              )
            end
          end

          it 'sets the vcenter datacenter and datastores for bosh managed vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'datacenter' => 'fake-vcenter-datacenter',
                'ephemeral_datastores_string' => 'e-fake-vcenter-datastores',
                'persistent_datastores_string' => 'p-fake-vcenter-datastores',
              )
            )
          end

          it 'sets the bosh product vm & template folders' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'bosh_vm_folder' => 'fake-vcenter-bosh_vm_folder',
                'bosh_template_folder' => 'fake-vcenter-bosh_template_folder',
              )
            )
          end

          it 'sets the bosh product disk path' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'bosh_disk_path' => 'fake-vcenter-bosh_disk_path'
              )
            )
          end
        end

        context 'when the IaaS is AWS' do
          before do
            test_settings_hash['iaas_type'] = 'aws'
            test_settings_hash['ops_manager'] = {
              'aws' => {
                'aws_access_key' => 'fake-aws-aws_access_key',
                'aws_secret_key' => 'fake-aws-aws_secret_key',
                'vpc_id' => 'fake-aws-vpc_id',
                'security_group_id' => 'fake-aws-security_group',
                'key_pair_name' => 'fake-aws-key_pair_name',
                'ssh_key' => 'fake-aws-ssh_key',
                'region' => 'fake-region',
              }
            }

            ops_manager_director.configure_iaas(test_settings_hash)
          end

          it 'configures the aws credentials for bosh to manage vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'access_key_id' => 'fake-aws-aws_access_key',
                'secret_access_key' => 'fake-aws-aws_secret_key',
              )
            )
          end

          it 'sets the aws security group for bosh managed vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'security_group' => 'fake-aws-security_group'
              )
            )
          end

          it 'sets the aws vpc for bosh managed vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'vpc_id' => 'fake-aws-vpc_id'
              )
            )
          end

          it 'sets the aws ssh key pair and private key for bosh managed vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'key_pair_name' => 'fake-aws-key_pair_name',
                'ssh_private_key' => 'fake-aws-ssh_key',
              )
            )
          end

          it 'sets the configured region' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'region' => 'fake-region'
              )
            )
          end
        end

        context 'when the IaaS is OpenStack' do
          before do
            test_settings_hash['iaas_type'] = 'openstack'
            test_settings_hash['ops_manager'] = {
              'openstack' => {
                'identity_endpoint' => 'fake-openstack-identity_endpoint',
                'username' => 'fake-openstack-username',
                'password' => 'fake-openstack-password',
                'tenant' => 'fake-openstack-tenant',
                'security_group_name' => 'fake-openstack-security_group_name',
                'key_pair_name' => 'fake-openstack-key_pair_name',
                'ssh_private_key' => 'fake-openstack-ssh_private_key',
                'connection_options' => 'fake-openstack-connection-options',
              }
            }

            ops_manager_director.configure_iaas(test_settings_hash)
          end

          it 'configures the openstack credentials for bosh to manage vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'identity_endpoint' => 'fake-openstack-identity_endpoint',
                'username' => 'fake-openstack-username',
                'password' => 'fake-openstack-password',
              )
            )
          end

          it 'sets the openstack tenant for bosh managed vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'tenant' => 'fake-openstack-tenant'
              )
            )
          end

          it 'sets the openstack security group for bosh managed vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'security_group' => 'fake-openstack-security_group_name'
              )
            )
          end

          it 'sets the openstack ssh key pair & private key for bosh managed vms' do
            expect(iaas_configuration).to have_received(:fill_iaas_settings).with(
              hash_including(
                'key_pair_name' => 'fake-openstack-key_pair_name',
                'ssh_private_key' => 'fake-openstack-ssh_private_key',
              )
            )
          end

          it 'sets the "connection_options" on the Advanced Infrastructure Config page' do
            expect(advanced_infrastructure_configuration).to have_received(:fill_advanced_infrastructure_config_settings).with(
              hash_including(
                'connection_options' => 'fake-openstack-connection-options'
              )
            )
          end
        end

        context 'configure blobstore' do
          shared_examples_for 's3 blobstore' do

            let(:test_settings_hash) do
              {
                'ops_manager' => {
                  's3_blobstore' => {
                    'endpoint' => 'http://example.com',
                    'bucket_name' => 'test-bucket',
                    'access_key_id' => 'test-access_key',
                    'secret_access_key' => 'test-secret_key',
                    'signature_version' => signature_version,
                    'region' => region,
                  }
                }
              }
            end

            it 'applies s3 settings correctly' do
              expect(browser).to receive(:fill_in).with('director_configuration[s3_blobstore_options][endpoint]', {:with => 'http://example.com'})
              expect(browser).to receive(:fill_in).with('director_configuration[s3_blobstore_options][bucket_name]', {:with => 'test-bucket'})
              expect(browser).to receive(:fill_in).with('director_configuration[s3_blobstore_options][access_key]', {:with => 'test-access_key'})
              expect(browser).to receive(:fill_in).with('director_configuration[s3_blobstore_options][secret_key]', {:with => 'test-secret_key'})

              if signature_version == 4
                expect(browser).to receive(:choose).with('V4 Signature')
                expect(browser).to receive(:fill_in).with('director_configuration[s3_blobstore_options][region]', {:with => region})
              end

              ops_manager_director.config_director(test_settings_hash['ops_manager'])
            end
          end

          context 'no default signature - defaults to v2' do
            let(:signature_version) { nil }
            let(:region) { nil }

            it_behaves_like 's3 blobstore'
          end

          context 'explicitly specified v2 signature' do
            let(:signature_version) { 2 }
            let(:region) { nil }

            it_behaves_like 's3 blobstore'
          end

          context 'explicitly specified v4 signature' do
            let(:signature_version) { 4 }
            let(:region) { 'us-east-1' }

            it_behaves_like 's3 blobstore'
          end
        end
      end

      describe '#add_availability_zones' do
        context 'when the infrastructure is AWS' do
          it 'navigates to and submits the availability zone form' do
            iaas_identifier_field = double(:iaas_identifier_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][iaas_identifier]', minimum: 1).and_return([iaas_identifier_field])

            ops_manager_director.add_availability_zones(OpsManagerUiDrivers::AWS_IAAS_TYPE, [{'iaas_identifier' => 'aws_az'}])

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-p-bosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-availability_zones-action').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][iaas_identifier]', minimum: 1).ordered
            expect(iaas_identifier_field).to have_received(:set).with('aws_az').ordered
            expect(browser).to have_received(:click_on).with('Save').ordered
          end
        end

        context 'when the infrastructure is OpenStack' do
          it 'navigates to and submits the availability zone form' do
            iaas_identifier_field = double(:iaas_identifier_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][iaas_identifier]', minimum: 1).and_return([iaas_identifier_field])

            ops_manager_director.add_availability_zones(OpsManagerUiDrivers::OPENSTACK_IAAS_TYPE, [{'iaas_identifier' => 'openstack_az'}])

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-p-bosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-availability_zones-action').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][iaas_identifier]', minimum: 1).ordered
            expect(iaas_identifier_field).to have_received(:set).with('openstack_az').ordered
            expect(browser).to have_received(:click_on).with('Save').ordered
          end
        end

        context 'when the infrastructure is anything else' do
          it 'navigates to and submits the availability zone form' do
            name_field = double(:name_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][name]', minimum: 1).and_return([name_field])
            cluster_field = double(:cluster_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][cluster]', minimum: 1).and_return([cluster_field])
            resource_pool_field = double(:resource_pool_field, set: nil)
            allow(browser).to receive(:all).with(:field, 'availability_zones[availability_zones][][resource_pool]', minimum: 1).and_return([resource_pool_field])

            vsphere_options = {'name' => 'vsphere_az', 'cluster' => 'vsphere_cluster', 'resource_pool' => 'vsphere_resource_pool'}
            ops_manager_director.add_availability_zones(OpsManagerUiDrivers::VSPHERE_IAAS_TYPE, [vsphere_options])

            expect(browser).to have_received(:visit).with('/').ordered
            expect(browser).to have_received(:click_on).with('show-p-bosh-configure-action').ordered
            expect(browser).to have_received(:click_on).with('show-availability_zones-action').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][name]', minimum: 1).ordered
            expect(name_field).to have_received(:set).with('vsphere_az').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][cluster]', minimum: 1).ordered
            expect(cluster_field).to have_received(:set).with('vsphere_cluster').ordered
            expect(browser).to have_received(:all).with(:field, 'availability_zones[availability_zones][][resource_pool]', minimum: 1).ordered
            expect(resource_pool_field).to have_received(:set).with('vsphere_resource_pool').ordered
            expect(browser).to have_received(:click_on).with('Save').ordered
          end
        end
      end

      describe '#configure_vm_passwords' do
        it 'navigates to and submits the vm_passwords form' do
          ops_manager_director.configure_vm_passwords

          expect(browser).to have_received(:click_on).with('Security').ordered
          expect(browser).to have_received(:choose).with('Generate passwords').ordered
          expect(browser).to have_received(:click_on).with('Save').ordered
          expect(browser).to have_received(:poll_up_to_times).ordered
          expect(browser).to have_received(:assert_text).with('Settings updated').ordered
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

      describe '#configure_trusted_certificates' do
        context 'when trusted certificates are present in the security configuration' do
          let(:test_settings_hash) do
            {
              'ops_manager' => {
                'trusted_certificates' => 'NO REALLY, I AM A CERTIFICATE THAT IS TOTALLY VALID',
              }
            }
          end

          it 'saves the certificates into the `Trusted Certificates` area' do
            ops_manager_director.configure_trusted_certificates(test_settings_hash.dig('ops_manager', 'trusted_certificates'))

            expect(browser).to have_received(:click_on).with('Security')
            expect(browser).to have_received(:fill_in).with('security_tokens[trusted_certificates]', with: 'NO REALLY, I AM A CERTIFICATE THAT IS TOTALLY VALID')
            expect(browser).to have_received(:click_on).with('Save')
          end
        end

        context 'when trusted_certificates are not configured' do
          let(:test_settings_hash) do
            {
              'ops_manager' => {
                'security_tokens' => {}
              }
            }
          end

          it 'does not save an empty value into the `Trusted Certificates` area' do
            ops_manager_director.configure_trusted_certificates(nil )

            expect(browser).not_to have_received(:click_on).with('Security')
            expect(browser).not_to have_received(:fill_in)
            expect(browser).not_to have_received(:click_on).with('Save')
          end
        end
      end
    end
  end
end
