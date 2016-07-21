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

      class Vcloud < Version17::Settings::Vcloud
      end

      class Vsphere < Version17::Settings::Vsphere
      end

      class AWS < Version17::Settings::AWS
      end

      class OpenStack < Version17::Settings::OpenStack
      end

      class Google < Version17::Settings::Google
      end

      class Azure < Version17::Settings::Azure
      end
    end
  end
end
