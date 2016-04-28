require 'ops_manager_ui_drivers/version17/product_dashboard'

module OpsManagerUiDrivers
  module Version18
    class ProductDashboard < Version17::ProductDashboard
      def delete_whole_installation
        method_deprecated!
      end

      def delete_installation_available?
        method_deprecated!
      end

      def product_available?(product_name, product_version)
        STDERR.puts 'OpsManagerUiDrivers product_dashboard.product_available? is deprecated, please use available_products#product_available?'
        Version18::AvailableProducts.new(browser: browser).product_available?(product_name, product_version)
      end

      def upgrade_product(product_name)
        STDERR.puts 'OpsManagerUiDrivers product_dashboard.upgrade_product is deprecated, please use available_products#add_product_to_install with a product name and version'
        Version18::AvailableProducts.new(browser: browser).add_product_to_install(product_name, nil)
      end

      def delete_unused_products
        STDERR.puts 'OpsManagerUiDrivers product_dashboard.delete_unused_products is deprecated, please use available_products#delete_unused_products'
        Version18::AvailableProducts.new(browser: browser).delete_unused_products
      end

      def reset_state(ops_manager)
        revert_pending_changes if revert_available?
        if ops_manager.settings_page.delete_installation_available?
          ops_manager.settings_page.delete_whole_installation_on_next_apply_updates
          apply_updates
          browser.poll_up_to_mins(15) do
            browser.expect(ops_manager.state_change_progress).to browser.be_state_change_success
          end
        end
      end

      private

      def method_deprecated!
        raise NotImplementedError, 'This method has been removed. You can find the new version on the UserSettings class'
      end
    end
  end
end
