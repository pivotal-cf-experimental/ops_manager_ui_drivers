require 'ops_manager_ui_drivers/version18/ops_manager_director'
using OpsManagerUiDrivers::BackportRefinements

module OpsManagerUiDrivers
  module Version19
    class OpsManagerDirector < Version18::OpsManagerDirector
      def initialize(browser:, iaas_configuration: Version19::BoshProductSections::IaasConfiguration.new(browser: browser))
        @browser = browser
        @iaas_configuration = iaas_configuration
      end

      def advanced_infrastructure_config
        @advanced_infrastructure_config ||= Version19::BoshProductSections::AdvancedInfrastructureConfig.new(browser: browser)
      end

      def availability_zones
        @availability_zones ||= Version19::BoshProductSections::AvailabilityZones.new(browser: browser)
      end

      def networks
        @networks ||= Version19::BoshProductSections::Networks.new(browser: browser)
      end
    end
  end
end
