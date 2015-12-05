require 'active_support'
require 'active_support/core_ext'
Dir[File.join(__dir__, '**', '*.rb')].each do |ops_manager_ui_drivers|
  require ops_manager_ui_drivers
end

module OpsManagerUiDrivers
  AWS_IAAS_TYPE = 'aws'.freeze
  OPENSTACK_IAAS_TYPE = 'openstack'.freeze
  VCLOUD_IAAS_TYPE = 'vcloud'.freeze
  VSPHERE_IAAS_TYPE = 'vsphere'.freeze
end
