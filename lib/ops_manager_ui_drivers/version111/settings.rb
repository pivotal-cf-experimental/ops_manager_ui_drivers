require 'ops_manager_ui_drivers/version110/settings'
using OpsManagerUiDrivers::BackportRefinements

module OpsManagerUiDrivers
  module Version111
    module Settings

      class Vcloud < Version110::Settings::Vcloud
      end

      class Vsphere < Version110::Settings::Vsphere
      end

      class AWS < Version110::Settings::AWS
      end

      class OpenStack < Version110::Settings::OpenStack
      end

      class Google < Version110::Settings::Google
      end

      class Azure < Version110::Settings::Azure
      end
    end
  end
end
