require 'ops_manager_ui_drivers/version15/product_dashboard'

module OpsManagerUiDrivers
  module Version16
    class ProductDashboard < Version15::ProductDashboard
      def upgrade_microbosh
        fail('No longer implemented in this version')
      end
    end
  end
end
