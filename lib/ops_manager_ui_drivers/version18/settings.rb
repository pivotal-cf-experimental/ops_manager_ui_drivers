using OpsManagerUiDrivers::BackportRefinements

module OpsManagerUiDrivers
  module Version18
    module Settings
      def self.for(test_settings)
        iaas_type = test_settings.dig('iaas_type')
        settings_class =
          [Vcloud, Vsphere, AWS, OpenStack].find do |klass|
            klass.works_with?(iaas_type)
          end or fail("Unsupported IaaS: #{iaas_type.inspect}")
        settings_class.new(test_settings)
      end

      class Vcloud < OpsManagerUiDrivers::Version17::Settings::Vcloud
      end

      class Vsphere < OpsManagerUiDrivers::Version17::Settings::Vsphere
      end

      class AWS < OpsManagerUiDrivers::Version17::Settings::AWS
      end

      class OpenStack < OpsManagerUiDrivers::Version17::Settings::OpenStack
      end
    end
  end
end
