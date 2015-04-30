require 'ops_manager_ui_drivers/wait_helper'

module OpsManagerUiDrivers
  module PageHelpers
    include OpsManagerUiDrivers::WaitHelper

    def om_1_1(ops_manager_url)
      @om_1_1 ||= create_web_ui(ops_manager_url, Version11)
    end

    def om_1_2(ops_manager_url)
      @om_1_2 ||= create_web_ui(ops_manager_url, Version12)
    end

    def om_1_3(ops_manager_url)
      @om_1_3 ||= create_web_ui(ops_manager_url, Version13)
    end

    def om_1_4(ops_manager_url)
      @om_1_4 ||= create_web_ui(ops_manager_url, Version14)
    end

    def om_rc(ops_manager_url)
      @om_1_5 ||= create_web_ui(ops_manager_url, Version15)
    end

    def api_1_1(host:, username:, password:)
      Version11::Api.new(host: host, user: username, password: password)
    end

    def api_1_2(host:, username:, password:)
      Version12::Api.new(host: host, user: username, password: password)
    end

    def api_1_3(host:, username:, password:)
      Version13::Api.new(host: host, user: username, password: password)
    end

    def api_1_4(host:, username:, password:)
      Version14::Api.new(host: host, user: username, password: password)
    end

    private

    def create_web_ui(ops_manager_url, version_module)
      Capybara.app_host = ops_manager_url
      page.driver.allow_url(Capybara.app_host)
      puts "Preparing to interact with #{version_module.inspect} at #{Capybara.app_host}"
      version_module::WebUi.new(browser: self)
    end
  end
end
