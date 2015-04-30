module OpsManagerUiDrivers
  module Version11
    class WebUi
      def initialize(browser:)
        @browser = browser
      end

      def login_page
        @login_page ||= Version11::Login.new(browser: browser)
      end

      def product_dashboard
        @product_dashboard ||= Version11::ProductDashboard.new(browser: browser)
      end

      def available_products
        @available_products ||= Version11::AvailableProducts.new(browser: browser)
      end

      def ops_manager_director
        @ops_manager_director ||= Version11::OpsManagerDirector.new(browser: browser)
      end

      def install_progress
        @install_progress ||= Version11::InstallProgress.new(browser: browser)
      end

      private

      attr_reader :browser

    end
  end
end
