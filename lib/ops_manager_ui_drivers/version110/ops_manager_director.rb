require 'ops_manager_ui_drivers/version19/ops_manager_director'

module OpsManagerUiDrivers
  module Version110
    class OpsManagerDirector < Version19::OpsManagerDirector
      def advanced_infrastructure_config
        @advanced_infrastructure_config ||= Version110::BoshProductSections::AdvancedInfrastructureConfig.new(browser: browser)
      end

      def availability_zones
        @availability_zones ||= Version110::BoshProductSections::AvailabilityZones.new(browser: browser)
      end

      def networks
        @networks ||= Version110::BoshProductSections::Networks.new(browser: browser)
      end
    end
  end
end
