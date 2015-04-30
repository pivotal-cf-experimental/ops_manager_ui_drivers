module OpsManagerUiDrivers
  module Version12
    class WebUi
      def initialize(browser:)
        @browser = browser
      end

      def login_page
        @login_page ||= Version12::Login.new(browser: browser)
      end

      def product_dashboard
        @product_dashboard ||= Version12::ProductDashboard.new(browser: browser)
      end

      def available_products
        @available_products ||= Version12::AvailableProducts.new(browser: browser)
      end

      def ops_manager_director
        @ops_manager_director ||= Version12::OpsManagerDirector.new(browser: browser)
      end

      def install_progress
        @install_progress ||= Version12::InstallProgress.new(browser: browser)
      end

      private

      attr_reader :browser

    end
  end
end
