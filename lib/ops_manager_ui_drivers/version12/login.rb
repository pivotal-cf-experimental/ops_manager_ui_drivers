module OpsManagerUiDrivers
  module Version12
    class Login
      def initialize(browser:)
        @browser = browser
      end

      def login(user:, password:)
        open_login_page
        browser.fill_in 'login[user_name]', with: user
        browser.fill_in 'login[password]', with: password
        browser.click_on 'login-action'
      end

      private

      attr_reader :browser

      def open_login_page
        browser.visit '/login'
      end
    end
  end
end
