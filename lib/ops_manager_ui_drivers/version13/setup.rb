module OpsManagerUiDrivers
  module Version13
    class Setup
      def initialize(browser: nil)
        @browser = browser
      end

      def setup_and_login(user:, password:)
        browser.visit '/setup'
        browser.fill_in 'user[user_name]', with: user
        browser.fill_in 'user[password]', with: password
        browser.fill_in 'user[password_confirmation]', with: password
        browser.check 'user_eula_accepted'
        browser.click_on 'create-user-action'
      end

      def login(user: nil, password: nil)
        browser.visit '/login'
        browser.fill_in 'login[user_name]', with: user
        browser.fill_in 'login[password]', with: password
        browser.click_on 'login-action'
      end

      def setup_or_login(user:, password:)
        browser.visit '/'

        if browser.current_path == '/setup'
          setup_and_login(user: user, password: password)
        elsif browser.current_path == '/login'
          login(user: user, password: password)
        end
      end

      private

      attr_reader :browser

    end
  end
end
