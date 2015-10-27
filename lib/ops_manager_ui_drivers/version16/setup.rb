module OpsManagerUiDrivers
  module Version16
    class Setup
      def initialize(browser: nil)
        @browser = browser
      end

      def setup_and_login(user:, password:)
        browser.visit '/setup'
        browser.fill_in 'setup[user_name]', with: user, wait: 4
        browser.fill_in 'setup[password]', with: password
        browser.fill_in 'setup[password_confirmation]', with: password
        browser.check 'setup_eula_accepted'
        browser.click_on 'create-setup-action'
      end

      def login(user: nil, password: nil)
        browser.visit '/login'
        browser.fill_in 'login[user_name]', with: user, wait: 4
        browser.fill_in 'login[password]', with: password
        browser.click_on 'login-action'

        unless browser.first('#main-page-marker')
          fail RuntimeError.new("failed to log in as #{user}/#{password}.")
        end
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
