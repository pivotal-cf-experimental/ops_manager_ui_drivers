module OpsManagerUiDrivers
  module Version18
    class ProductDashboard < OpsManagerUiDrivers::Version17::ProductDashboard
      def delete_whole_installation
        method_deprecated!
      end

      def delete_installation_available?
        method_deprecated!
      end

      private

      def method_deprecated!
        raise NotImplementedError, 'This method has been removed. You can find the new version on the UserSettings class'
      end
    end
  end
end
