require 'ops_manager_ui_drivers/version110/ops_manager_director'

module OpsManagerUiDrivers
  module Version111
    class OpsManagerDirector < Version110::OpsManagerDirector
      def advanced_infrastructure_config
        @advanced_infrastructure_config ||= Version111::BoshProductSections::AdvancedInfrastructureConfig.new(browser: browser)
      end

      def availability_zones
        @availability_zones ||= Version111::BoshProductSections::AvailabilityZones.new(browser: browser)
      end

      def networks
        @networks ||= Version111::BoshProductSections::Networks.new(browser: browser)
      end
    end
  end
end
